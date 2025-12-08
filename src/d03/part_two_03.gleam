//// Day 3

import file_streams/file_stream.{type FileStream}
import file_streams/file_stream_error
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/string

const total_digits = 12

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
          let greatest_joltage = max_joltage(number_list, total_digits, 0)
          case greatest_joltage {
            Ok(greatest_joltage) -> process_file(stream, joltage + greatest_joltage)
            _ -> Error(Nil)
          }
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
    _ -> {
      io.println_error("Unkwon error reading the line: ")
      Error(Nil)
    }
  }
}

pub fn remove_values(numbers: List(t), target: t) -> List(t) {
  numbers
  |> list.drop_while(satisfying: fn(n) { n != target })
  |> list.drop(up_to: 1)
}

fn max_joltage(numbers: List(Int), digits: Int, joltage: Int) -> Result(Int, Nil) {
  case digits {
    0 -> Ok(joltage)
    _ -> {
      let list_length = list.length(numbers)
      let up_to = list_length - digits + 1
      let first_digits = list.take(from: numbers, up_to: up_to)
      let max = list.max(first_digits, int.compare)
      let power = int.power(10, int.to_float(digits) -. 1.0)
      case max, power {
        Ok(max), Ok(power) -> {
          let power = float.truncate(power)
          let value = max * power
          let numbers = remove_values(numbers, max)
          max_joltage(numbers, digits - 1, joltage + value)
        }
        _, _ -> Error(Nil)
      }
    }
  }
}
