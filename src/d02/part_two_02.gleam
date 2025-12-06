//// Day 2

import gleam/int
import gleam/io
import gleam/list
import gleam/string

const ids = "5542145-5582046,243-401,884211-917063,1174-1665,767028-791710,308275-370459,285243789-285316649,3303028-3361832,793080-871112,82187-123398,7788-14096,21-34,33187450-33443224,2750031-2956556,19974-42168,37655953-37738891,1759-2640,55544-75026,9938140738-9938223673,965895186-966026269,502675-625082,11041548-11204207,1-20,3679-7591,8642243-8776142,40-88,2872703083-2872760877,532-998,211488-230593,3088932-3236371,442734-459620,8484829519-8484873271,5859767462-5859911897,9987328-10008767,656641-673714,262248430-262271846"

// const ids = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"

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
  case value > 9 {
    True -> {
      let string_value = int.to_string(value)
      let string_length = string.length(string_value)
      let parts = list.range(from: 2, to: string_length)
      let string_list = string.to_graphemes(string_value)

      let invalid_for_some_number_parts =
        list.any(parts, fn(number_parts) {
          invalid_for_number_parts(string_list, string_length, number_parts)
        })
      case invalid_for_some_number_parts {
        True -> acc + value
        False -> acc
      }
    }
    False -> acc
  }
}

fn invalid_for_number_parts(
  string_list: List(String),
  string_length: Int,
  parts: Int,
) -> Bool {
  case string_length % parts == 0 {
    True -> {
      let part_length = string_length / parts
      let grouped_graphemes = group_every_n(string_list, part_length)
      let assert [first, ..] = list.take(grouped_graphemes, up_to: 1)
      all_groups_equal(grouped_graphemes, first, True)
    }
    False -> False
  }
}

fn all_groups_equal(l: List(List(value)), value: List(value), acc: Bool) -> Bool {
  let length = list.length(l)
  case length {
    0 -> acc
    _ -> {
      let assert [first, ..] = list.take(l, up_to: 1)
      let l = list.drop(l, up_to: 1)
      all_groups_equal(l, value, acc && { first == value })
    }
  }
}

pub fn group_every_n(l: List(value), n: Int) -> List(List(value)) {
  group_every_n_recursive(list.reverse(l), list.new(), n)
}

fn group_every_n_recursive(
  l: List(value),
  new_list: List(List(value)),
  n: Int,
) -> List(List(value)) {
  let taken_elements = list.take(from: l, up_to: n)
  let l = list.drop(l, up_to: n)
  case list.length(taken_elements) {
    0 -> new_list
    _ -> {
      let taken_elements = list.reverse(taken_elements)
      let new_list = list.prepend(to: new_list, this: taken_elements)
      group_every_n_recursive(l, new_list, n)
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
