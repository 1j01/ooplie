
###

Library "Process(es)"

"exit"
"exit this program"
"exit the program" # maybe; could be a child process, even if that would be a weird way of saying it
"exit program"
"exit this process"
"exit the process" # maybe; could be a child process, even if that would be a weird way of saying it
"exit process"
"end this process" # bad way of saying to exit
	process.exit()

"kill process <pid>"
"kill <pid>"
"end process <pid>"
"end <pid>"
	process.kill()

"command-line arguments"
"command line arguments"
"arguments from the command-line"
"arguments"
"args"
"argv"
	process.argv

"current memory usage"
"this process's memory usage"
"memory usage of this process"
"memory usage"
"How much memory is this process using?"
	process.memoryUsage()kb

"set the process's title to <text>"
"name the process <text>"
"call the process <text>" # bad
	process.title = text

###
