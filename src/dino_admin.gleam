import argv
import csv.{ReadFileError}
import gleam/io
import gleam/string

pub fn main() {
  case argv.load().arguments {
    ["import", "path", path] -> {
      io.println("Going to read path: " <> path)

      case csv.read_csv(path) {
        Ok(content) ->
          io.println("Read CSV successfullt: " <> string.inspect(content))
        Error(ReadFileError(msg)) ->
          io.println("Failed to read CSV file: " <> msg)
      }
    }
    _ -> io.println("No path is provided")
  }
}
