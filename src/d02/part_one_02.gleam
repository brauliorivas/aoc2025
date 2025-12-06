//// Day 2

import gleam/io
import gleam/int
import gleam/list
import gleam/string

const ids = "5542145-5582046,243-401,884211-917063,1174-1665,767028-791710,308275-370459,285243789-285316649,3303028-3361832,793080-871112,82187-123398,7788-14096,21-34,33187450-33443224,2750031-2956556,19974-42168,37655953-37738891,1759-2640,55544-75026,9938140738-9938223673,965895186-966026269,502675-625082,11041548-11204207,1-20,3679-7591,8642243-8776142,40-88,2872703083-2872760877,532-998,211488-230593,3088932-3236371,442734-459620,8484829519-8484873271,5859767462-5859911897,9987328-10008767,656641-673714,262248430-262271846"
const acc_initial_value = 0

pub fn main() -> Int {
  let ids_ranges = string.split(ids, on: ",")

  list.fold(ids_ranges, acc_initial_value, reduce_ranges)
}

type Range {
  Range(start: Int, end: Int)
}

fn reduce_ranges(acc: Int, value: String) -> Int {
  let range = get_range(value)
  case range {
    Ok(range) -> {
      let range = list.range(from: range.start, to: range.end)
      acc + list.fold(range, acc_initial_value, reduce_range)
    }
    _ -> {
      io.println_error("There was an error processing this range: " <> value)
      acc
    }
  }
}

fn reduce_range(acc: Int, value: Int) -> Int {
  let string_value = int.to_string(value)
  let string_length = string.length(string_value)

  case string_length % 2 == 0 {
    True -> {
      let half_length = string_length / 2
      let first_half = string.slice(from: string_value, at_index: 0, length: half_length)
      let second_half = string.slice(from: string_value, at_index: half_length, length: half_length)

      let first_number = int.parse(first_half)
      let second_number = int.parse(second_half)
      case first_number, second_number {
        Ok(first_number), Ok(second_number) -> {
          case first_number == second_number {
            True -> acc + value
            False -> acc
          }
        }
        _, _ -> {
          io.println("Error parsing numbers: " <> first_half <> " and " <> second_half <> ".")
          acc
        }
      }
    }
    False -> {
      acc
    }
  }
}

fn get_range(id_range: String) -> Result(Range, Nil) {
  let assert [start, end] = string.split(id_range, on: "-")
  let start = int.parse(start)
  let end = int.parse(end)

  case start, end {
    Ok(start), Ok(end) -> Ok(Range(start, end))
    _, _ -> Error(Nil)
  }
}
