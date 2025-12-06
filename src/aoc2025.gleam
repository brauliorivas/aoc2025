import d01/part_one_01
import d01/part_two_01
import d02/part_one_02
import d02/part_two_02
import gleam/io

pub fn main() -> Nil {
  io.println("Hello from aoc2025!")

  // Day 1
  // let _ = echo part_one_01.main("input/1.txt")
  // let _ = echo part_two_01.main("input/1.txt")
  // // Day 2
  let _ = echo part_one_02.main()
  let _ = echo part_two_02.main()

  Nil
}
