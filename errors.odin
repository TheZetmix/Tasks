package tasks

import "core:fmt"
import "core:os"

errors_appeared := 0

error :: proc(format: string, args: ..any) {
    fmt.printf("tasks: \033[31m[ERROR]\033[0m: ")
    fmt.fprintf(os.stderr, format, ..args)
    fmt.printf("\n")
    errors_appeared += 1
}

info :: proc(format: string, args: ..any) {
    fmt.printf("tasks: \033[32m[INFO]\033[0m: ")
    fmt.printf(format, ..args)
    fmt.printf("\n")
}

error_check_and_exit :: proc() {
    if errors_appeared != 0 {
        fmt.println("tasks:", errors_appeared, "errors total")
        os.exit(1)
    }
}
