# LAST_fast_pipeline

Fast pipeline for near real time processing of short exposures on LAST.

Based on Unit.Slaves delivering image content and headers to pipeline workers, via POSIX
message queues and shared memory segments.

[Reference discussion](https://github.com/EranOfek/AstroPack/discussions/828) in AstroPack.

## TBD:

- Lifecycle of workers (who starts them, system service or observation code, on demand);
  when they terminate
- lifetime of shared memory and message queues (they have to live till workers have load
  to process)
- number of workers per telescope (depends on average process time per image/exposure time)
- depth of image ringbuffer and header queue (depends on latency of workers, i.e. max
  processing time)
- mechanism for delivering immediate results