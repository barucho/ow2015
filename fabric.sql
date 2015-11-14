/*****************************
 *   Lesson  - fabric *
 * mysql01 - master,manager
 * mysql02 - slave
 * 14.11.2015 - baruch@brillix.co.il created 
 ****************************/
/* on mysql01 */

-- /etc/mysql/fabric.cfg

mysqlfabric manage setup
[INFO] 1439728172.722521 - MainThread - Initializing persister: user (root), server (localhost:3308), database (fabric).
Finishing initial setup
=======================
Password for admin user is not yet set.
Password for admin/xmlrpc:
Repeat Password:
Password set.
Password set.

mysqlfabric group lookup_servers DATACENTER2
/*start fabric */
mysqlfabric manage start &
/*create group */
mysqlfabric group create DATACENTER2

mysqlfabric group create DATACENTER1
Password for admin:
Fabric UUID:  5ca1ab1e-a007-feed-f00d-cab3fe13249e
Time-To-Live: 1

                               uuid finished success result
------------------------------------ -------- ------- ------
316842f7-d7be-410d-a8c0-f3f6d77fe5ba        1       1      1

state success          when                                                   description
----- ------- ------------- -------------------------------------------------------------
   3       2   1.43973e+09 Triggered by <mysql.fabric.events.Event object at 0x27a2790>.
   4       2   1.43973e+09                             Executing action (_create_group).
   5       2   1.43973e+09                              Executed action (_create_group).


   mysqlfabric group add DATACENTER1 192.168.56.200:3306
   Password for admin:
   Fabric UUID:  5ca1ab1e-a007-feed-f00d-cab3fe13249e
   Time-To-Live: 1

                                   uuid finished success result
   ------------------------------------ -------- ------- ------
   dcca82f4-9c26-42ba-ab67-d2d82b4a7fa6        1       1      1

   state success          when                                                   description
   ----- ------- ------------- -------------------------------------------------------------
       3       2   1.43973e+09 Triggered by <mysql.fabric.events.Event object at 0x2226b50>.
       4       2   1.43973e+09                               Executing action (_add_server).
       5       2   1.43973e+09                                Executed action (_add_server).




       mysqlfabric group add DATACENTER1 192.168.56.200:3307
       Password for admin:
       Fabric UUID:  5ca1ab1e-a007-feed-f00d-cab3fe13249e
       Time-To-Live: 1

                                       uuid finished success result
       ------------------------------------ -------- ------- ------
       a57b544a-56ed-48ef-95c5-28ceeec0ae94        1       1      1

       state success          when                                                   description
       ----- ------- ------------- -------------------------------------------------------------
           3       2   1.43973e+09 Triggered by <mysql.fabric.events.Event object at 0x2226b50>.
           4       2   1.43973e+09                               Executing action (_add_server).
           5       2   1.43973e+09                                Executed action (_add_server).


           mysqlfabric group lookup_servers DATACENTER1

                                    server_uuid             address    status      mode weight
           ------------------------------------ ------------------- --------- --------- ------
           afb304dd-37a1-11e5-b849-080027e33f7b 192.168.56.200:3306 SECONDARY READ_ONLY    1.0
           f47df729-385c-11e5-bd0e-080027e33f7b 192.168.56.200:3307 SECONDARY READ_ONLY    1.0


           /*set sec server as master */

           mysqlfabric group promote DATACENTER1 --slave_id='f47df729-385c-11e5-bd0e-080027e33f7b'
           Password for admin:
           [INFO] 1439729066.105802 - Executor-0 - Master has changed from afb304dd-37a1-11e5-b849-080027e33f7b to None.
           [INFO] 1439729066.177011 - Executor-0 - Master has changed from None to f47df729-385c-11e5-bd0e-080027e33f7b.
           Fabric UUID:  5ca1ab1e-a007-feed-f00d-cab3fe13249e
           Time-To-Live: 1

                                           uuid finished success result
           ------------------------------------ -------- ------- ------
           f7573021-0c17-43c2-b440-92388b8c9d7b        1       1      1

           state success          when                                                   description
           ----- ------- ------------- -------------------------------------------------------------
               3       2   1.43973e+09 Triggered by <mysql.fabric.events.Event object at 0x2042890>.
               4       2   1.43973e+09                      Executing action (_define_ha_operation).
               5       2   1.43973e+09                       Executed action (_define_ha_operation).
               3       2   1.43973e+09 Triggered by <mysql.fabric.events.Event object at 0x21b3210>.
               4       2   1.43973e+09                   Executing action (_check_candidate_switch).
               5       2   1.43973e+09                    Executed action (_check_candidate_switch).
               3       2   1.43973e+09 Triggered by <mysql.fabric.events.Event object at 0x21b3250>.
               4       2   1.43973e+09                       Executing action (_block_write_switch).
               5       2   1.43973e+09                        Executed action (_block_write_switch).
               3       2   1.43973e+09 Triggered by <mysql.fabric.events.Event object at 0x21b3290>.
               4       2   1.43973e+09                       Executing action (_wait_slaves_switch).
               5       2   1.43973e+09                        Executed action (_wait_slaves_switch).
               3       2   1.43973e+09 Triggered by <mysql.fabric.events.Event object at 0x21b32d0>.
               4       2   1.43973e+09                      Executing action (_change_to_candidate).
               5       2   1.43973e+09                       Executed action (_change_to_candidate).



/*test cluster */
mysqlfabric group health DATACENTER1
