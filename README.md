# Tasks

### NOTE: The original idea was taken from [Tsoding](https://github.com/tsoding) from his series of videos about 3d software rendering game (https://www.youtube.com/@TsodingDaily) and also improved for full CLI support

This utility allows you to create, delete or close tasks for projects directly in the project folder  

### Quick start:
Since the utility is written in the Odin programming language, you need to [download](https://odin-lang.org/docs/install/) a compiler for this language   
After this, you can compile and install the utility:  
```console
$ make build
$ sudo make install
```
### Usage:
To create a new task, use the new subcommand  
```console
$ tasks new 'Some task'
```
To set the task priority, specify it after the title  
```console
$ tasks new 'Another task' 60
```
To view all existing tasks, use the list subcommand (tasks are sorted by priority):  
```console
$ tasks list
tasks: [INFO]: 2 tasks total
OPENED task At: PRIORITY[60] Another task (2026.01.01)
OPENED task St: PRIORITY[100] Some task (2026.01.01)
```
To close a task, use the close subcommand  
It requires a task hash, you can view it through the tasks list  
```console
$ tasks list
tasks: [INFO]: 1 tasks total
OPENED task At: PRIORITY[60] Another task (2026.01.01)
$ tasks close At
$ tasks list
tasks: [INFO]: 1 tasks total
CLOSED task At: PRIORITY[60] Another task (2026.01.01)
```
To reopen a closed task, use the open subcommand:  
```console
$ tasks open At
```
To rename a task, use the rename subcommand:  
```console
$ tasks rename Utn 'Updated task name'
```
To change task priority, use the priority subcommand:  
```console
$ tasks priority Utn 25
```
To remove a task, use the remove subcommand  
```console
$ tasks list
tasks: [INFO]: 1 tasks total
CLOSED task At: PRIORITY[60] Another task (2026.01.01)
$ tasks remove At
$ tasks list
tasks: [INFO]: 0 tasks total
There is nothing to do :(
$ 
```
Task file format:  
Each task is stored as a file in the todo/ directory with the following format:  
```text
Task title
STATE (OPENED/CLOSED)
Priority number
Date of creation
```
Subcommands summary:  
```text
new <title> [priority] - create a new task (default priority: 100)
list - show all tasks sorted by priority
close <hash> - mark task as closed
open <hash> - reopen a closed task
rename <hash> <new-title> - change task title
priority <hash> <new-priority> - change task priority
remove <hash> - permanently delete task
update <hash> - update date of task creation
```

Hashes are generated based on the first letters of the task name, for example:  
Some task - St  
Refactor args parsing - Rap  
Another task with many many words and bla bla bla - Atwmmwabbb  
