# Time based Pan & Scan
This script for MPV reads a meta file with information about aspect ratio and vertical shift for specific time intervals. Thus allows one to change several settings (e.g. zoom) when the aspect ratio cahges inside a movie or show. For example on a constant image height (CIH) screen the 16:9 parts can be shrunk to gain the constant height.

The second application is selecting the correct framing when cropping a video to a larger aspect ratio (e.g. 16:9 to 21:9). The center is not always the part of the image the director would chose. So this can be specified in the meta file.

The meta file has the following format: with each row a new time interval begins. First value is the timestamp in seconds. Second value is the aspect ratio (e.g. 2.4 or 1.78) and the third value is the vertical shift (-1.0 to +1.0).

**Example**
0 2.4 0
13.847 2.0 0
63.397 2.4 0
370.37 2.0 0


The script prints the exact timestamp to command line. You can step exactly to the right frame with the configured keys im MPV when paused and read the value for the meta file.
