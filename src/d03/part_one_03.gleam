//// Day 3

import file_streams/file_stream.{type FileStream}
import file_streams/file_stream_error
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn main(filename: String) -> Result(Int, Nil) {
  let stream = file_stream.open_read(filename)

  case stream {
    Ok(stream) -> process_file(stream, 0)
    _ -> Error(Nil)
  }
}

fn process_file(stream: FileStream, joltage: Int) -> Result(Int, Nil) {
  case file_stream.read_line(stream) {
    Ok(line) -> {
      let line = string.trim(line)
      let string_list = string.to_graphemes(line)
      let number_list = list.try_map(over: string_list, with: int.parse)
      case number_list {
        Ok(number_list) -> {
          let greatest_joltage = max_joltage(number_list)
          process_file(stream, joltage + greatest_joltage)
        }
        Error(_err) -> {
          io.println_error("There was an error processing this line: " <> line)
          Error(Nil)
        }
      }
    }
    Error(file_stream_error.Eof) -> {
      let _ = file_stream.close(stream)
      Ok(joltage)
    }
    Error(err) -> {
      io.println_error("Unkwon error reading the line: ")
      echo err
      Error(Nil)
    }
  }
}

fn max_joltage(numbers: List(Int)) -> Int {
  let reversed_list = list.reverse(numbers)
  let max_value =
    list.max(list.drop(from: reversed_list, up_to: 1), with: int.compare)
  case max_value {
    Ok(max_value) -> {
      let new_list =
        list.drop_while(in: numbers, satisfying: fn(x) { x != max_value })
      let new_list = list.drop(from: new_list, up_to: 1)
      let second_max_value = list.max(new_list, with: int.compare)
      case second_max_value {
        Ok(second_max_value) -> 10 * max_value + second_max_value
        Error(_err) -> {
          io.println_error("Can't find a second max value")
          0
        }
      }
    }
    Error(_err) -> {
      io.println_error("Can't find a max value")
      0
    }
  }
}
