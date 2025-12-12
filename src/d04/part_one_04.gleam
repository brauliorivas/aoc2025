//// Day 4

import file_streams/file_stream.{type FileStream}
import file_streams/file_stream_error
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/string

pub fn main(filename: String) -> Result(Int, Nil) {
  let stream = file_stream.open_read(filename)

  case stream {
    Ok(stream) -> process_file(stream, new_matrix())
    _ -> Error(Nil)
  }
}

fn process_file(stream: FileStream, matrix: Matrix) -> Result(Int, Nil) {
  case file_stream.read_line(stream) {
    Ok(line) -> {
      let matrix = build_matrix(line, matrix)
      process_file(stream, matrix)
    }
    Error(file_stream_error.Eof) -> {
      let _ = file_stream.close(stream)
      print_matrix(matrix)
      Ok(accessable_rolls(matrix))
    }
    _ -> {
      io.println_error("Unkwon error reading the line: ")
      Error(Nil)
    }
  }
}

type Cell {
  RollCell
  EmptyCell
}

type Matrix {
  Matrix(value: Dict(Int, Dict(Int, Cell)))
}

fn new_matrix() -> Matrix {
  Matrix(value: dict.new())
}

fn matrix_rows(matrix: Matrix) -> Int {
  dict.size(matrix.value)
}

fn append_row(matrix: Matrix, row: Dict(Int, Cell)) -> Matrix {
  let rows = matrix_rows(matrix)
  let new_value = dict.insert(matrix.value, rows + 1, row)
  Matrix(value: new_value)
}

fn build_matrix(row: String, matrix: Matrix) -> Matrix {
  string.trim(row)
  |> string.to_graphemes
  |> list.map(with: fn(element) {
    case element {
      "." -> EmptyCell
      "@" -> RollCell
      _ -> EmptyCell
    }
  })
  |> list.index_map(fn(element, index) { #(index, element) })
  |> dict.from_list
  |> append_row(matrix, _)
}

fn print_matrix(matrix: Matrix) -> Nil {
  dict.each(matrix.value, fn(_k, v) {
    dict.each(v, fn(_k, v) {
      case v {
        RollCell -> io.print("@")
        EmptyCell -> io.print(".")
      }
    })
    io.println("")
  })
}

fn accessable_rolls(matrix: Matrix) -> Int {
  dict.fold(over: matrix.value, from: 0, with: fn(acc, irow, row_dict) {
    acc
    + dict.fold(over: row_dict, from: 0, with: fn(acc, icolumn, cell) {
      let adjancent = adjacent_indexes(irow, icolumn)
      let nearby_rolls =
        list.fold(adjancent, 0, with: fn(acc, pair) {
          let irow = pair.0
          let icolumn = pair.1
          case dict.get(matrix.value, irow) {
            Ok(row) -> {
              case dict.get(row, icolumn) {
                Ok(value) -> {
                  case value {
                    RollCell -> acc + 1
                    EmptyCell -> acc
                  }
                }
                _ -> acc
              }
            }
            _ -> acc
          }
        })
      case nearby_rolls < 4 && cell == RollCell {
        True -> acc + 1
        False -> acc
      }
    })
  })
}

fn adjacent_indexes(row: Int, column: Int) -> List(#(Int, Int)) {
  list.new()
  |> list.prepend(#(row - 1, column - 1))
  |> list.prepend(#(row - 1, column))
  |> list.prepend(#(row - 1, column + 1))
  |> list.prepend(#(row, column - 1))
  |> list.prepend(#(row, column + 1))
  |> list.prepend(#(row + 1, column - 1))
  |> list.prepend(#(row + 1, column))
  |> list.prepend(#(row + 1, column + 1))
}
