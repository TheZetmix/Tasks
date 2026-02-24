package tasks

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:time"
import "core:strings"
import "core:slice"

SubCommand :: struct {
    name: string,
    handler: proc()
}

update_line_by_hash :: proc(hash, content: string, line: int) {
    data, success := os.read_entire_file(fmt.tprintf("todo/%s", hash))
    if success != true do error("invalid hash")
    error_check_and_exit()
    
    lines, _ := strings.split_lines(cast(string)data)
    
    lines[line] = content
    
    new_data := strings.join(lines, "\n"); defer delete(new_data)
    os.write_entire_file(fmt.tprintf("todo/%s", hash), transmute([]byte)new_data)
}

get_line_content :: proc(hash: string, line: int) -> string {
    data, success := os.read_entire_file(fmt.tprintf("todo/%s", hash))
    if success != true do error("invalid hash")
    error_check_and_exit()
    
    lines, _ := strings.split_lines(cast(string)data)
    
    return lines[line]
}

subcommands :: []SubCommand{
    {
        "new",
        proc() {
            if len(os.args) == 2 do error("task title not provided")
            error_check_and_exit()
            
            title := os.args[2]
            priority := 100
            
            if len(os.args) == 4 {
                priority, _ = strconv.parse_int(os.args[3])
            }
            
            hour, minute, sec := time.clock_from_time(time.now())
            data := fmt.tprintf("%s\nOPENED\n%d", title, priority)
            filename := fmt.tprintf(
                "todo/%04d%02d%02d-%02d%02d%02d",
                time.year(time.now()), time.month(time.now()), time.day(time.now()),
                hour, minute, sec
            )
            
            info("'%s' was added", title)
            
            os.write_entire_file(filename, transmute([]byte)data)
        }
    },
    {
        "list",
        proc() {
            entries, _ := os.open("./todo", os.O_RDONLY); defer os.close(entries)
            files, _ := os.read_dir(entries, -1)
            
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
            
            for i in files {
                data, _ := os.read_entire_file(i.fullpath); defer delete(data)
                lines := strings.split_lines(cast(string)data)
                
                title := lines[0]
                state := lines[1]
                priority := lines[2]
                
                fmt.printf("\033[%dm%s\033[0m task %s: \033[34mPRIORITY\033[0m[%s] %s\n", 31 if state == "OPENED" else 32, state, i.name, priority, title)
            }
            if len(files) == 0 do fmt.println("There is nothing to do :(")
        }
    },
    {
        "close",
        proc() {
            if len(os.args) == 2 do error("task hash not provided")
            error_check_and_exit()
            
            hash := os.args[2]
            
            update_line_by_hash(hash, "CLOSED", 1)
            
            info("'%s' was closed", get_line_content(hash, 0))
        }
    },
    {
        "open",
        proc() {
            if len(os.args) == 2 do error("task hash not provided")
            error_check_and_exit()
            
            hash := os.args[2]
            
            update_line_by_hash(hash, "OPENED", 1)
            
            info("'%s' was opened", get_line_content(hash, 0))
        }
    },
    {
        "remove",
        proc() {
            if len(os.args) == 2 do error("task hash not provided")
            error_check_and_exit()
            
            hash := os.args[2]
            
            err := os.remove(fmt.tprintf("todo/%s", hash))
            
            if err != nil do error("invalid hash")
            info("'%s' was removed", get_line_content(hash, 0))
        }
    },
    {
        "rename",
        proc() {
            if len(os.args) == 2 do error("task hash not provided")
            error_check_and_exit()
            
            hash := os.args[2]
            
            if len(os.args) == 3 do error("new task title not provided")
            error_check_and_exit()
            
            title := os.args[3]
            
            update_line_by_hash(hash, title, 0)
            info("'%s' was renamed", get_line_content(hash, 0))
        }
    },
    {
        "priority",
        proc() {
            if len(os.args) == 2 do error("task hash not provided")
            error_check_and_exit()
            
            hash := os.args[2]
            
            if len(os.args) == 3 do error("new priority not provided")
            error_check_and_exit()
            
            priority := os.args[3]
            
            update_line_by_hash(hash, priority, 2)
            info("priority of '%s' was changed", get_line_content(hash, 0))
        }
    }
}

print_subcommands :: proc() {
    fmt.println("available subcommands:")
    for i in subcommands {
        fmt.println("  -", i.name)
    }
}

str_is_subcommand :: proc(str: string) -> bool {
    for i in subcommands do if i.name == str do return true
    return false
}

main :: proc() {
    if len(os.args) == 1 {
        error("first argument must be a subcommand")
        print_subcommands()
    }
    
    if len(os.args) == 2 && !str_is_subcommand(os.args[1]) {
        error("unknown subcommand %s", os.args[1])
        print_subcommands()
    }
    
    error_check_and_exit()
    
    os.make_directory("todo")
    
    // if the provided sumcommand is in the list, call its handler
    for i in subcommands {
        if i.name == os.args[1] do i.handler()
    }
}
