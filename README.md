# LAST_fast_pipeline

Fast pipeline for near real time processing of short exposures on LAST.

Based on `Unit.Slaves` delivering image content and headers to pipeline workers, via POSIX
message queues and shared memory segments.

[Reference discussion](https://github.com/EranOfek/AstroPack/discussions/828) in AstroPack.

## Dependencies:

- [matlab-posix-mqueue](https://github.com/EastEriq/matlab-posix-mqueue)
- [matlab-shared-pointer](https://github.com/EastEriq/matlab-shared-pointer)

## Running the examples:

- The main directory of this repo, its subdir `ancillaries`, `matlab-posix-mqueue`,
  `matlab-shared-pointer` have all to be in matlab's `PATH`.

### On a LAST machine:

#### online run

- set up one or more observing `Unit`s. That can be done in an interactive matlab shell, or
  via the superunit like customarily done during observation nights.
- pass to all desired cameras the magic parameter `Unit.Camera{i}.SharedRingBufferDim`. Any
  positive integer value enables image sharing. You may want e.g. to give in the superunit
  session `S.send('for i=1:4; Unit.Camera{i}.SharedRingBufferDim=10); end')`
- images taken during a live mode acquisition (e.g., `Unit.takeExposure([],1,100)`) will
  be automatically shared among processes.
- in a separate matlab session on the east or west unit computer, run `worker_skeleton`.
  Without modifying it, the script polls the queue for camera 1 on the east node, and that
  of camera 3 on the west node. A different camera can be selected changing `Tid` in
  `[HeaderQueue,RingBuffer]=connectIPC(Tid)` in `worker_skeleton.m`. The script will run
   till interrupted with Ctrl-C and report the images which it dequeues and reads.


#### offline run

- on an arbitrary last node computer (east or west), run `injection_simulator`
  in a matlab session. This will automatically look for the most recent raw
  images directory which contains at least 20 `*sci_raw_Image_1.fits*` files.
  The script will pick up the directory for camera 1 on east computers and for
  camera 3 on west ones; it will cyclically enqueue a new image
  every couple of seconds, until stopped with Ctrl-C.
- In a different matlab session, run `worker_skeleton`. This will also run till
  interrupted with Ctrl-C, and report the images which it dequeues and reads.

### On a non last machine:

- Copy several LAST images into a directory of your choice. Likely, you'd want to
  work with `*sci_raw_Image_1.fits*` files (compressed or not).
- in `injection_simulator.m`, replace the line `imdir=chooseSampleImDir(Uid,Cid);` with
  `imdir=`_your_image_directory_
- in a matlab session, run `injection_simulator`. In a different matlab session, run
  `worker_skeleton`. Both scripts will run till interrupted with Ctrl-C. The first
  one will cyclically enqueue a new image from `imdir` every couple of seconds; the second
  one will report the images which it dequeues and reads.


## TBD:

- Lifecycle of workers (who starts them, system service or observation code, on demand);
  when they terminate
- lifetime of shared memory and message queues (they have to live till workers have load
  to process)
- number of workers per telescope (depends on average process time per image/exposure time)
- depth of image ringbuffer and header queue (depends on latency of workers, i.e. max
  processing time)
- mechanism for delivering immediate results