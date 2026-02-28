package tasks

import "core:os"
import "core:time"
import "core:strings"
import "core:slice"
import "core:fmt"
import "core:strconv"

cli_subcommands :: []SubCommand{
    {
        "new",
        "create a new task",
        proc(args: []string) {
            if len(args) == 2 do error("task title not provided")
            
            title := args[2]
            priority := 100
            
            if len(args) == 4 {
                priority, _ = strconv.parse_int(args[3])
            }
            
            created := fmt.tprintf(
                "%04d%02d%02d",
                time.year(time.now()), time.month(time.now()), time.day(time.now()),
            )
            
            data := fmt.tprintf("%s\nOPENED\n%d\n%s", title, priority, created)
            
            builder := strings.builder_make(); defer strings.builder_destroy(&builder)
            for i in strings.split(title, " ") {
                strings.write_byte(&builder, i[0])
            }
            
            filename := fmt.tprintf("%s/%s", todo_dir, strings.to_string(builder))
            
            info("'%s' was added (hash: %s)", title, strings.to_string(builder))
            
            os.write_entire_file(filename, transmute([]byte)data)
        }
    },
    {
        "list",
        "list all tasks",
        proc(args: []string) {
            entries, _ := os.open(todo_dir, os.O_RDONLY); defer os.close(entries)
            files, _ := os.read_dir(entries, -1)
            hashes: [dynamic]string; defer delete(hashes)
            
            info("%d tasks total", len(files))
            
            slice.sort_by(files[:], proc(a, b: os.File_Info) -> bool {
                data_a, _ := os.read_entire_file(a.fullpath); defer delete(data_a)
                data_b, _ := os.read_entire_file(b.fullpath); defer delete(data_b)
                
                lines_a := strings.split_lines(cast(string)data_a)
                lines_b := strings.split_lines(cast(string)data_b)
                
                priority_a, _ := strconv.parse_int(lines_a[2])
                priority_b, _ := strconv.parse_int(lines_b[2])
                
                return cast(int)priority_a < cast(int)priority_b
            })
            
            for i in files do append(&hashes, i.name)
            
            for i in hashes {
                data := parse_task_by_hash(i)
                
                year := data.date[0:4]
                month := data.date[4:6]
                day := data.date[6:8]
                
                created_fancy := strings.concatenate({year, ".", month, ".", day})
                
                fmt.printf("\033[%dm%s\033[0m task %s: \033[34mPRIORITY\033[0m[%d]\t %s (%s)\n", 31 if data.state == .OPENED else 32, data.state, i, data.priority, data.title, created_fancy)
            }
            if len(files) == 0 do fmt.println("There is nothing to do :(")
        }
    },
    {
        "close",
        "close task",
        proc(args: []string) {
            if len(args) == 2 do error("task hash not provided")
            
            hash := args[2]
            
            data := parse_task_by_hash(hash)
            data.state = .CLOSED
            modify_hash(hash, data)
            info("%s was closed", data.title)
        }
    },
    {
        "open",
        "open task",
        proc(args: []string) {
            if len(args) == 2 do error("task hash not provided")
            
            hash := args[2]
            
            data := parse_task_by_hash(hash)
            data.state = .OPENED
            modify_hash(hash, data)
            info("%s was opened", data.title)
        }
    },
    {
        "remove",
        "delete task permanently",
        proc(args: []string) {
            if len(args) == 2 do error("task hash not provided")
            
            hash := args[2]
            validate_hash(hash)
            
            data := parse_task_by_hash(hash)
            err := os.remove(fmt.tprintf("%s/%s", todo_dir, hash))
            info("'%s' was removed", data.title)
        }
    },
    {
        "rename",
        "rename task",
        proc(args: []string) {
            if len(args) == 2 do error("task hash not provided")
            
            hash := args[2]
            
            if len(args) == 3 do error("new task title not provided")
            
            title := args[3]
            
            data := parse_task_by_hash(hash)
            data.title = title
            modify_hash(hash, data)
            info("%s was renamed", data.title)
        }
    },
    {
        "priority",
        "change priority of the task",
        proc(args: []string) {
            if len(args) == 2 do error("task hash not provided")
            
            hash := args[2]
            
            if len(args) == 3 do error("new priority not provided")
            
            priority := args[3]
            
            data := parse_task_by_hash(hash)
            data.priority, _ = strconv.parse_int(priority)
            modify_hash(hash, data)
            info("priority of %s was changed", data.title)
        }
    },
    {
        "update",
        "update date of task creation",
        proc(args: []string) {
            if len(args) == 2 do error("task hash not provided")
            
            hash := args[2]
            
            data := parse_task_by_hash(hash)
            data.date = fmt.tprintf(
                "%04d%02d%02d",
                time.year(time.now()), time.month(time.now()), time.day(time.now()),
            )
            modify_hash(hash, data)
            info("date of %s was updated", data.title)
        }
    }
}

main :: proc() {
    if len(os.args) == 1 {
        print_subcommands(cli_subcommands)
        error("first argument must be a subcommand")
    }
    
    if len(os.args) == 2 && !str_is_subcommand(os.args[1], cli_subcommands) {
        print_subcommands(cli_subcommands)
        error("unknown subcommand %s", os.args[1])
    }
    
    os.make_directory(todo_dir)
    
    // if the provided sumcommand is in the list, call its handler
    execute_subcommand_by_name(os.args[1], cli_subcommands)
}
