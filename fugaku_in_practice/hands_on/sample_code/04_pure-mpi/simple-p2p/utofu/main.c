/* Copyright 2025 Research Organization for Information Science and Technology */
/* Reference
 * [1] "Technical Computing Suite V4.0L20 Development Studio uTofu User's Guide"
 *     Chap.5
 *     https://software.fujitsu.com/jp/manual/manualindex/p21000155e.html
 * [2] https://github.com/RIKEN-LQCD/jacobi2d
 * */
#include <assert.h>
#include <limits.h>
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <utofu.h>

#define MAX_MSG_SIZE (1<<20)
#define BUFFER_SIZE MAX_MSG_SIZE
#define MAX_NITR 10000

/* send data and confirm its completion */
static void send(utofu_vcq_hdl_t vcq_hdl, utofu_vcq_id_t rmt_vcq_id,
                 utofu_stadd_t lcl_send_stadd, utofu_stadd_t rmt_recv_stadd, size_t length,
                 uint64_t edata, uintptr_t cbvalue, unsigned long int post_flags)
{
   int rc;
   /* instruct the TNI to perform a Put communication */
   utofu_put(vcq_hdl, rmt_vcq_id, lcl_send_stadd, rmt_recv_stadd, length,
             edata, post_flags, (void *)cbvalue);
   /* confirm the TCQ notification */
   if (post_flags & UTOFU_ONESIDED_FLAG_TCQ_NOTICE) {
      void *cbdata;
      do {
         rc = utofu_poll_tcq(vcq_hdl, 0, &cbdata);
      } while (rc == UTOFU_ERR_NOT_FOUND);
      assert(rc == UTOFU_SUCCESS);
      assert((uintptr_t)cbdata == cbvalue);
   }
   /* confirm the local MRQ notification */
   if (post_flags & UTOFU_ONESIDED_FLAG_LOCAL_MRQ_NOTICE) {
      struct utofu_mrq_notice notice;
      do {
         rc = utofu_poll_mrq(vcq_hdl, 0, &notice);
      } while (rc == UTOFU_ERR_NOT_FOUND);
      assert(rc == UTOFU_SUCCESS);
      assert(notice.notice_type == UTOFU_MRQ_TYPE_LCL_PUT);
      assert(notice.edata == edata);
   }
}

/* confirm receiving data */
static void recv(utofu_vcq_hdl_t vcq_hdl, 
                 uint64_t edata, unsigned long int post_flags)
{
   int rc;
   /* confirm the remote MRQ notification  */
   if (post_flags & UTOFU_ONESIDED_FLAG_REMOTE_MRQ_NOTICE) {
      struct utofu_mrq_notice notice;
      do {
         rc = utofu_poll_mrq(vcq_hdl, 0, &notice);
      } while (rc == UTOFU_ERR_NOT_FOUND);
      assert(rc == UTOFU_SUCCESS);
      assert(notice.notice_type == UTOFU_MRQ_TYPE_RMT_PUT);
      assert(notice.edata == edata);
   }
}

int main(int argc, char *argv[])
{
   int NITR;
   int lcl_rank, rmt_rank, np;
   int rc;

   unsigned long int post_flags;
   size_t num_tnis;
   size_t length;

   uint64_t edata;
   uintptr_t cbvalue;

   int *src_buf;
   volatile int *rcv_buf;

   utofu_tni_id_t tni_id, *tni_ids;
   utofu_vcq_hdl_t vcq_hdl;
   utofu_vcq_id_t lcl_vcq_id, rmt_vcq_id;
   utofu_stadd_t lcl_send_stadd, lcl_recv_stadd, rmt_recv_stadd;
   struct utofu_onesided_caps *onesided_caps;

   length = sizeof(int)*(BUFFER_SIZE);

   MPI_Init(NULL, NULL);
   MPI_Comm_rank(MPI_COMM_WORLD, &lcl_rank);
   MPI_Comm_size(MPI_COMM_WORLD, &np);

   if ( np != 2 ) {
     if ( lcl_rank == 0 ) {
        fprintf(stdout,"Error: Number of MPI tasks is strictly set as 2 in this code\n");
     }
     MPI_Finalize();
     return EXIT_FAILURE;
   }

   rmt_rank = (lcl_rank == 0) ? 1 : 0;

   /* get an ID of a TNI available for one-sided communication */
   rc = utofu_get_onesided_tnis(&tni_ids, &num_tnis);
   if (rc != UTOFU_SUCCESS || num_tnis == 0) {
      MPI_Abort(MPI_COMM_WORLD, 1);
      return EXIT_FAILURE;
   }
   tni_id = tni_ids[0];
   free(tni_ids);

   src_buf = (int *)malloc( length );
   rcv_buf = (int *)malloc( length );

   /* query the capabilities of one-sided communication of the TNI */
   utofu_query_onesided_caps(tni_id, &onesided_caps);

   /* create a VCQ and get its VCQ ID */
   utofu_create_vcq(tni_id, 0, &vcq_hdl);
   utofu_query_vcq_id(vcq_hdl, &lcl_vcq_id);

   /* register memory regions and get their STADDs */
   utofu_reg_mem(vcq_hdl, (void *)src_buf, length, 0, &lcl_send_stadd);
   utofu_reg_mem(vcq_hdl, (void *)rcv_buf, length, 0, &lcl_recv_stadd);

   /* notify peer processes of the VCQ ID and the STADD */
   MPI_Sendrecv(&lcl_vcq_id, 1, MPI_UINT64_T, rmt_rank, 0,
                &rmt_vcq_id, 1, MPI_UINT64_T, rmt_rank, 0,
                MPI_COMM_WORLD, MPI_STATUS_IGNORE);
   MPI_Sendrecv(&lcl_recv_stadd, 1, MPI_UINT64_T, rmt_rank, 0,
                &rmt_recv_stadd, 1, MPI_UINT64_T, rmt_rank, 0,
                MPI_COMM_WORLD, MPI_STATUS_IGNORE);

   /* embed the default communication path coordinates into the received VCQ ID.*/
   utofu_set_vcq_id_path(&rmt_vcq_id, NULL);

   for ( int ii = 0 ; ii < BUFFER_SIZE; ++ii ) {
      src_buf[ii] = ii;
      rcv_buf[ii] = INT_MAX;
   }

   /* Start Ping-Pong changing message length 
    * We perform ping-pong  the remote MRQ notification               */
   post_flags = UTOFU_ONESIDED_FLAG_TCQ_NOTICE |
                UTOFU_ONESIDED_FLAG_REMOTE_MRQ_NOTICE |
                UTOFU_ONESIDED_FLAG_LOCAL_MRQ_NOTICE;

   if ( lcl_rank == 0 ) {
      fprintf(stdout,"avg_msg_bytes avg_latency_sec avg_bandwidth_mbps\n");
   }

   for ( int size = 1 ; size < MAX_MSG_SIZE; size *= 2)
   {
      size_t msglen = sizeof(int)*size;

      if ( msglen < 4096 ) {
         NITR = MAX_NITR;
      } else if ( msglen < 65535 ) {
         NITR = MAX_NITR / 10;
      } else if ( msglen < 1048576 ) {
         NITR = MAX_NITR / 100;
      } else {
         NITR = 20;
      }

      MPI_Barrier(MPI_COMM_WORLD);

      double elp0 = MPI_Wtime();

      for (int i = 0; i < NITR; ++i) {
          /* The edata that can be used is 8 bytes. Because of that, edata is reset to 0
           * times every 256 times. */
         edata = i % (1UL << (8 * onesided_caps->max_edata_size));
         cbvalue = i;
         if (lcl_rank == 0) {
            send(vcq_hdl, rmt_vcq_id, lcl_send_stadd, rmt_recv_stadd, msglen,
                 edata, cbvalue, post_flags);
            recv(vcq_hdl,  edata, post_flags);
	    /* simple check for receiving data */
            assert(rcv_buf[0] == src_buf[0]);
	    rcv_buf[0] = INT_MAX;
#if 0
            /* exhausted check for receiving data */
            assert(rcv_buf[0] == src_buf[0]);
            assert(rcv_buf[size-1] == src_buf[size-1]);
            for ( int ii = 0 ; ii < size; ++ii ) {
               rcv_buf[ii] = INT_MAX;
            }
#endif
         } else {
            recv(vcq_hdl, edata, post_flags);
	    /* simple check for receiving data */
            assert(rcv_buf[0] == src_buf[0]);
	    rcv_buf[0] = INT_MAX;
#if 0
            /* exhausted check for receiving data */
            assert(rcv_buf[0] == src_buf[0]);
            assert(rcv_buf[size-1] == src_buf[size-1]);
            for ( int ii = 0 ; ii < size; ++ii ) {
               rcv_buf[ii] = INT_MAX;
            }
#endif
            send(vcq_hdl, rmt_vcq_id, lcl_send_stadd, rmt_recv_stadd, msglen,
                 edata, cbvalue, post_flags);
            }
      } /* End of loop: i */
      MPI_Barrier(MPI_COMM_WORLD);

      double elp = MPI_Wtime() - elp0;

      /* output */
      if ( lcl_rank == 0 ) { 
         elp = (0.5*elp)/NITR;
         double bw = ((double)msglen/ 1048576.0)/elp;
         fprintf(stdout,"%10zu %14.3e %14.5f\n", msglen, elp, bw);
      }

   } /* End of loop: size */

   /* free resources */
   utofu_dereg_mem(vcq_hdl, lcl_send_stadd, 0);
   utofu_dereg_mem(vcq_hdl, lcl_recv_stadd, 0);
   utofu_free_vcq(vcq_hdl);

   free( src_buf );

   MPI_Finalize();
   return EXIT_SUCCESS;
}
