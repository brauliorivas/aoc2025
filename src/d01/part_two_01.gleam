//// Day 1

import file_streams/file_stream.{type FileStream}
import file_streams/file_stream_error
import gleam/int
import gleam/string

const start = 50

const lower_limit = 0

const upper_limit = 99

const initial_password = 0

pub fn main(filename: String) -> Result(Int, Nil) {
  let stream = file_stream.open_read(filename)

  case stream {
    Ok(stream) -> process_file(stream, start, initial_password)
    _ -> Error(Nil)
  }
}

fn process_file(
  stream: FileStream,
  position: Int,
  password: Int,
) -> Result(Int, Nil) {
  case file_stream.read_line(stream) {
    Ok(string) -> {
      let lock = handle_rotation(string, position, password)
      case lock {
        Ok(lock) -> {
          let new_pos = lock.position
          let new_pass = lock.password
          case new_pos < lower_limit || new_pos > upper_limit {
            True -> Error(Nil)
            False -> process_file(stream, new_pos, new_pass)
          }
        }
        _ -> Error(Nil)
      }
    }
    Error(file_stream_error.Eof) -> {
      case file_stream.close(stream) {
        Ok(Nil) -> Ok(password)
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

type Lock {
  Lock(position: Int, password: Int)
}

fn handle_rotation(
  rotation: String,
  position: Int,
  password: Int,
) -> Result(Lock, Nil) {
  case rotation {
    "L" <> number -> decrease(position, password, number)
    "R" <> number -> increase(position, password, number)
    _ -> Error(Nil)
  }
}

fn parse_rotation(rotation: String) -> Result(Int, Nil) {
  rotation |> string.trim |> int.parse
}

fn increase(position: Int, password: Int, rotation: String) -> Result(Lock, Nil) {
  let rotation = parse_rotation(rotation)
  case rotation {
    Ok(rotation) -> {
      let cycles = rotation / 100
      let rotation = rotation % 100
      case rotation {
        0 -> Ok(Lock(position, password + cycles))
        rotation -> {
          let position = position + rotation
          let password = case position > 99 {
            True -> password + 1
            False -> password
          }
          let position = case position > 99 {
            True -> position - 100
            False -> position
          }
          Ok(Lock(position, password))
        }
      }
    }
    _ -> Error(Nil)
  }
}

fn decrease(position: Int, password: Int, rotation: String) -> Result(Lock, Nil) {
  let rotation = parse_rotation(rotation)
  case rotation {
    Ok(rotation) -> {
      let cycles = rotation / 100
      let rotation = rotation % 100
      case rotation {
        0 -> Ok(Lock(position, password + cycles))
        rotation -> {
          let position = position - rotation
          let password = case position <= 0 {
            True -> password + 1
            False -> password
          }
          let position = case position < 0 {
            True -> 100 + position
            False -> position
          }
          Ok(Lock(position, password))
        }
      }
    }
    _ -> Error(Nil)
  }
}
