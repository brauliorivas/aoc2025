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
      Ok(removed_rolls(matrix, 0))
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

fn append_row(row: Dict(Int, Cell), matrix: Matrix) -> Matrix {
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
  |> append_row(matrix)
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

type Coordinate {
  Coordinate(row: Int, col: Int)
}

fn removable_rolls(matrix: Matrix) -> List(Coordinate) {
  dict.fold(over: matrix.value, from: list.new(), with: fn(l, irow, row_dict) {
    let new_coordinates = dict.fold(over: row_dict, from: list.new(), with: fn(l, icolumn, cell) {
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
        True -> list.prepend(l, Coordinate(row: irow, col: icolumn))
        False -> l
      }
    })
    list.append(l, new_coordinates)
  })
}

fn remove_rolls(matrix: Matrix, coordinates: List(Coordinate)) -> Matrix {
  list.fold(over: coordinates, from: matrix, with: fn(matrix, coordinate) {
    let row = dict.get(matrix.value, coordinate.row)
    case row {
      Ok(row) -> {
        let new_row = dict.delete(from: row, delete: coordinate.col)
        Matrix(value: dict.insert(into: matrix.value, for: coordinate.row, insert: new_row))
      }
      _ -> matrix
    }
  })
}

fn removed_rolls(matrix: Matrix, total: Int) -> Int {
  let removable = removable_rolls(matrix)
  let n_removable = list.length(removable)
  case n_removable {
    0 -> total
    _ -> {
      let matrix = remove_rolls(matrix, removable)
      removed_rolls(matrix, total + n_removable)
    }
  }
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
