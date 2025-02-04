package main
import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"
import "core:strconv"
import "core:slice"

Task :: struct {
    complete: bool,
    title: string
}

o_ConsoleToStringMax :: proc(_max_size: int) -> string {
    buf := make([]byte, _max_size)
    //defer mem.free(buf.data)

    num_bytes, err := os.read(os.stdin, buf[:]);
    if err != 0 {
        fmt.println("error")
    }

    input_temp := string(buf[:num_bytes - 1])
    return strings.clone(input_temp)
}

o_ConsoleToString :: proc() -> string {
    return o_ConsoleToStringMax(256)
}

ConsoleToInt :: proc() -> int {
    // import "core:strconv"
    input := ConsoleToString()

    result, err := strconv.parse_int(input)
    if err == false {
        fmt.println("Error converting string to int:", err)
        return 0
    }
    
    return result
}

ConsoleToString :: proc{ o_ConsoleToString, o_ConsoleToStringMax}


save_tasks :: proc(filename: string, tasks: []Task) {
    sb := strings.builder_make()

    for task in tasks {
        // Represent the boolean as "1" for true and "0" for false.
        complete_str := "0"
        if task.complete {
            complete_str = "1"
        }

        strings.write_string(&sb, complete_str)
        strings.write_string(&sb, "\t")
        strings.write_string(&sb, task.title)
        strings.write_string(&sb, "\n")
    }

    if !os.write_entire_file(filename, sb.buf[:]) {
        fmt.println("Failed to save file!")
    }
}

load_tasks :: proc(_file_path: string) -> []Task {
    tasks: [dynamic]Task

    data, ok := os.read_entire_file(_file_path, context.allocator)
	if !ok {
		return tasks[:]
	}
	defer delete(data, context.allocator)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		parts := strings.split(line, "\t")

        if len(parts) != 2 {
            continue;
        }

        task: Task        
        
        if parts[0] == "1" {
            task.complete = true
        } else {
            task.complete = false
        }

        task.title = strings.clone(parts[1])
        append(&tasks, task)
	}

    return tasks[:]
}

Welcome :: proc() {
    fmt.println("//////////////")
    fmt.println("//// Todo ////")
    fmt.println("//////////////")
}

List :: proc( _tasks: [dynamic]Task) {
    fmt.println("Tasks: ")
    length := len(_tasks)
    for i := 0; i < length; i += 1 {
        if _tasks[i].complete {
            fmt.println( i, "[x]", _tasks[i].title)
        } else {
            fmt.println( i, "[ ]", _tasks[i].title)
        }
    }
    fmt.println("")
}

Add :: proc( _tasks: ^[dynamic]Task) {
    input := ConsoleToString()

    task: Task = {
        false,
        input    } 

    append(_tasks, task)
}

Complete :: proc( _tasks: ^[dynamic]Task) {
    fmt.print("Enter Id: ")
    id := ConsoleToInt()

    if id < 0 || id >= len(_tasks) {
        fmt.println("Id out of range!")
        return
    }

    _tasks[id].complete = true
}

main :: proc() {
    tasks : [dynamic]Task = slice.clone_to_dynamic(load_tasks("task.txt"))

    Welcome()

    for {
        fmt.println("Menu")
        fmt.println("1. List")
        fmt.println("2. Add")
        fmt.println("3. Complete")
        fmt.println("4. Save")
        fmt.println("5. Load")
        fmt.println("0. Exit")

        input := ConsoleToString()

        if input == "1" {
            List(tasks)
        } else if input == "2" {
            Add(&tasks)
        } else if input == "3" {
            Complete(&tasks)
        } else if input == "4" {
            save_tasks("task.txt", tasks[:])
        } else if input == "5" {
            clear(&tasks)
            tasks = slice.clone_to_dynamic(load_tasks("task.txt"))
        } else if input == "0" {
            save_tasks("task.txt", tasks[:])
            return 
        } else {
            
            fmt.println("Could not match user input.")
        }
        
    }
}