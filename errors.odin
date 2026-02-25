package tasks

import "core:fmt"
import "core:os"

error :: proc(format: string, args: ..any) {
    fmt.printf("tasks: \033[31m[ERROR]\033[0m: ")
    fmt.fprintf(os.stderr, format, ..args)
    fmt.printf("\n")
    os.exit(1)
}

info :: proc(format: string, args: ..any) {
    fmt.printf("tasks: \033[32m[INFO]\033[0m: ")
    fmt.printf(format, ..args)
    fmt.printf("\n")
}
