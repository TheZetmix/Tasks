# Tasks

### NOTE: The original idea was taken from [Tsoding](https://github.com/tsoding) from his series of videos about 3d software rendering game (https://www.youtube.com/@TsodingDaily)

This utility allows you to create, delete or close tasks for projects directly in the project folder

### Quick start:
Since the utility is written in the Odin programming language, you need to [download](https://odin-lang.org/docs/install/) a compiler for this language
After this, you can compile and install the utility:
```console
$ sudo make build install
```

### Usage:

To create a new task, use the new subcommand
Example:
```console
$ tasks new 'Some task'
```
To set the task priority, specify it after the title:
```console 
$ tasks new 'Another task' 60
```

To view all existing tasks, use the list subcommand
To close a task, use the close subcommand
It requires a task hash, you can view it through the tasks list
Example:
```console
$ tasks list
OPENED task 20260224-101252: PRIORITY[60] Another task
$ tasks close 20260224-101252
$ tasks list
CLOSED task 20260224-101252: PRIORITY[60] Another task
```
To remove a task, use the remove subcommand
Example:
```console
$ tasks list
CLOSED task 20260224-101252: PRIORITY[60] Another task
$ tasks remove 20260224-101252
$ tasks list
$ 
```
