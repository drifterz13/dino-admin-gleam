import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, Some}
import gleam/string
import gsv
import simplifile

pub type CameraLotRow {
  CameraLotRow(
    status: Option(String),
    name: Option(String),
    price: Option(Float),
    shipping_cost: Option(Float),
    tax: Option(Float),
    repair_cost: Option(Float),
    price_to_sell: Option(Float),
    sell_price: Option(Float),
    url: Option(String),
    note: Option(String),
    paid_by: Option(String),
  )
}

pub type CsvError {
  ReadFileError(String)
}

pub fn read_csv(path: String) -> Result(List(CameraLotRow), CsvError) {
  case simplifile.read(path) {
    Ok(str) -> {
      let csv_str = case str {
        "_" <> _rest -> str |> string.replace("_", "")
        _ -> str
      }
      let assert Ok(rows) = csv_str |> gsv.to_dicts
      rows |> list.map(map_camera_lot) |> Ok
    }
    Error(err) -> err |> simplifile.describe_error |> ReadFileError |> Error
  }
}

fn init_camera_lot() -> CameraLotRow {
  CameraLotRow(
    name: Some(""),
    status: Some(""),
    price: Some(0.0),
    shipping_cost: Some(0.0),
    tax: Some(0.0),
    repair_cost: Some(0.0),
    price_to_sell: Some(0.0),
    sell_price: Some(0.0),
    url: Some(""),
    note: Some(""),
    paid_by: Some(""),
  )
}

fn map_column(col: String) -> Result(String, Nil) {
  let norm_col =
    col
    |> string.trim
    |> string.lowercase
    |> string.replace(each: " ", with: "_")
  case norm_col {
    "status" | "name" | "price" | "total_price" | "url" | "paid_by" ->
      Ok(norm_col)
    "ค่าส่ง" -> Ok("shipping_cost")
    "ภาษี" -> Ok("tax")
    "ค่าซ่อม" -> Ok("repair_cost")
    "ราคาจะขาย" -> Ok("price_to_sell")
    "ราคาขายจริง" -> Ok("sell_price")
    "หมายเหตุ" -> Ok("note")
    _ -> Error(Nil)
  }
}

pub fn map_string_price(val: String) -> Float {
  case val {
    "THB" <> price -> {
      price
      |> string.replace("\u{00a0}", "")
      |> string.replace(",", "")
      |> map_string_to_float
    }
    price -> price |> map_string_to_float
  }
}

fn map_string_to_float(val: String) -> Float {
  case val |> int.parse {
    Ok(i) -> i |> int.to_float
    Error(_) -> {
      case val |> float.parse {
        Ok(p) -> p
        Error(_) -> 0.0
      }
    }
  }
}

pub fn map_camera_lot(data: Dict(String, String)) {
  data
  |> dict.fold(init_camera_lot(), fn(cam_lot, key, value) {
    case key |> map_column {
      Ok(col) -> {
        case col {
          "status" -> CameraLotRow(..cam_lot, status: Some(value))
          "name" -> CameraLotRow(..cam_lot, name: Some(value))
          "price" ->
            CameraLotRow(..cam_lot, price: value |> map_string_price |> Some)
          "shipping_cost" ->
            CameraLotRow(
              ..cam_lot,
              shipping_cost: value |> map_string_price |> Some,
            )
          "tax" ->
            CameraLotRow(..cam_lot, tax: value |> map_string_price |> Some)
          "repair_cost" ->
            CameraLotRow(
              ..cam_lot,
              repair_cost: value |> map_string_price |> Some,
            )
          "price_to_sell" ->
            CameraLotRow(
              ..cam_lot,
              price_to_sell: value |> map_string_price |> Some,
            )
          "sell_price" ->
            CameraLotRow(
              ..cam_lot,
              sell_price: value |> map_string_price |> Some,
            )
          "url" -> CameraLotRow(..cam_lot, url: Some(value))
          "note" -> CameraLotRow(..cam_lot, note: Some(value))
          "paid_by" -> CameraLotRow(..cam_lot, paid_by: Some(value))
          _ -> cam_lot
        }
      }
      Error(_) -> cam_lot
    }
  })
}
