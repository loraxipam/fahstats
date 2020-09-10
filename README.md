# fahstats
Folding@Home stats script, especially useful in Conky

## Usage
You can set the path to the F@H log file as the default in the variable in the script, or pass the F@H log file path to this script as $FAHLOG to override that.

You can choose a specific work unit and slot by setting the variables in the script, too.

It will show you the time that the percentages were reached. It also calculates for you the time that a percent increase takes, giving you a ballpark rate.

If a previous completed workunit is in the log file, it will give you the points for that workunit.

## Note
There are two scripts you can use. One just gives a quick summary and the other shows you the previous few percentage milestones.
