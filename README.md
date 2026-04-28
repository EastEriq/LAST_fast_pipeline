# LAST_fast_pipeline

Fast pipeline for near real time processing of short exposures on LAST.

Based on Unit.Slaves delivering image content and headers to pipeline workers, via POSIX
message queues and shared memory segments.

[Reference discussion](https://github.com/EranOfek/AstroPack/discussions/828) in AstroPack.

## Dependences:

- [matlab-posix-mqueue](https://github.com/EastEriq/matlab-posix-mqueue)
- [matlab-shared-pointer](https://github.com/EastEriq/matlab-shared-pointer)

## Running the examples:

- The main directory of this repo, its subdir `ancillaries`, `matlab-posix-mqueue`,
  `matlab-shared-pointer` have all to be in matlab's `PATH`.

### On a last machine:

### On a non last machine:

- Copy several last images into a directory of your choice. Likely, you'd want to
  work with `*sci_raw_Image_1.fits*` files (compressed or not).
- in `injection_simulator.m`, replace the line `imdir=chooseSampleImDir(Uid,Cid);` with
  `imdir=`_your_image_directory_
- in a matlab session, run `injection_simulator`. In a different matlab session, run
  `worker_skeleton`. Both scripts will run till interrupted with Ctrl-c. The first


## TBD:

- Lifecycle of workers (who starts them, system service or observation code, on demand);
  when they terminate
- lifetime of shared memory and message queues (they have to live till workers have load
  to process)
- number of workers per telescope (depends on average process time per image/exposure time)
- depth of image ringbuffer and header queue (depends on latency of workers, i.e. max
  processing time)
- mechanism for delivering immediate results