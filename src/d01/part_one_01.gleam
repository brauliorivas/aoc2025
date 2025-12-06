//// Day 1

import file_streams/file_stream.{type FileStream}
import file_streams/file_stream_error
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/string

const start = 50

pub fn main(filename: String) -> Option(Int) {
  let stream = file_stream.open_read(filename)

  case stream {
    Ok(stream) -> process_file(stream, start, 0)
    _ -> None
  }
}

fn process_file(stream: FileStream, position: Int, password: Int) -> Option(Int) {
  case file_stream.read_line(stream) {
    Ok(string) -> {
      let #(new_pos, new_pass) = handle_rotation(string, position, password)
      process_file(stream, new_pos, new_pass)
    }
    Error(file_stream_error.Eof) -> {
      let _ = file_stream.close(stream)
      Some(password)
    }
    _ -> None
  }
}

fn handle_rotation(
  rotation: String,
  position: Int,
  password: Int,
) -> #(Int, Int) {
  case rotation {
    "L" <> number -> decrease(position, password, number)
    "R" <> number -> increase(position, password, number)
    _ -> #(position, password)
  }
}

fn parse_rotation(rotation: String) {
  rotation |> string.trim |> int.parse
}

fn increase(position: Int, password: Int, rotation: String) {
  let rotation = parse_rotation(rotation)
  case rotation {
    Ok(rotation) -> {
      let rotation = rotation % 100
      let new_position = position + rotation
      let new_position = case new_position > 99 {
        True -> new_position - 100
        False -> new_position
      }
      #(new_position, new_password(new_position, password))
    }
    _ -> #(position, password)
  }
}

fn decrease(position: Int, password: Int, rotation: String) {
  let rotation = parse_rotation(rotation)
  case rotation {
    Ok(rotation) -> {
      let rotation = rotation % 100
      let new_position = position - rotation
      let new_position = case new_position < 0 {
        True -> 100 + new_position
        False -> new_position
      }
      #(new_position, new_password(new_position, password))
    }
    _ -> #(position, password)
  }
}

fn new_password(position: Int, old_password: Int) -> Int {
  case position {
    0 -> old_password + 1
    _ -> old_password
  }
}
