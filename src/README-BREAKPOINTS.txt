*** NOTE: syntax of kphp has changed ***

SYNTAX:

  kphp run <initial-config> <pgm> [--config]
  kphp resume <config> [--config]
  kphp <pgm> // implicit use of 'init-config.xml' as start configuration

****************************
*** BREAKPOINTS TUTORIAL ***
****************************

We run 'test.php', and ask kphp to show the configuration:

    scripts/kphp run init-config.xml example-breakpoint.php --config
   
The program contains a breakpoint, so the configuration is stuck
(this can be seen by inspecting the <k> cell). 
What we want to do is save this configuration to a file, and ask kphp
to resume it later on (i.e. moving on from the breakpoint.

    scripts/kphp run init-config.xml example-breakpoint.php --config > config.xml

Now, all we need to do to resume the computation is:

    scripts/kphp resume config.xml
   
Again, if we want to see the configuration:

    scripts/kphp resume config.xml --config
   
Since there are no more breakpoints, the last configuration should 
have an empty <k> cell
