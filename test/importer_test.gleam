import camera/importer.{CameraLotRow}
import gleam/dict
import gleam/list
import gleam/option.{Some}
import gleeunit/should

pub fn map_camera_lot_test() {
  dict.from_list([
    #("Status", "In-progress"),
    #("Name", "Canon IXY 930is"),
    #("Price", "THB\u{00a0}5600.45"),
    #("ค่าส่ง", "THB\u{00a0}450.50"),
    #("ภาษี", "THB\u{00a0}350.0"),
    #("ค่าซ่อม", "THB\u{00a0}600"),
    #("ราคาจะขาย", "THB\u{00a0}7890.0"),
    #("ราคาขายจริง", "THB\u{00a0}7990.0"),
    #("Url", "https://www.digidino.com"),
    #("หมายเหตุ", "-"),
    #("Paid by", "Mix"),
  ])
  |> importer.map_camera_lot
  |> should.equal(CameraLotRow(
    status: Some("In-progress"),
    name: Some("Canon IXY 930is"),
    price: Some(5600.45),
    shipping_cost: Some(450.5),
    tax: Some(350.0),
    repair_cost: Some(600.0),
    price_to_sell: Some(7890.0),
    sell_price: Some(7990.0),
    url: Some("https://www.digidino.com"),
    note: Some("-"),
    paid_by: Some("Mix"),
  ))
}

pub fn map_price_string_test() {
  let prices = ["THB\u{00a0}100", "THB\u{00a0}1,500.60", "THB\u{00a0}2,000.8"]
  prices
  |> list.map(importer.map_string_price)
  |> should.equal([100.0, 1500.6, 2000.8])
}

pub fn map_int_string_price_test() {
  let int_prices = ["100", "1500", "2000"]

  int_prices
  |> list.map(importer.map_string_price)
  |> should.equal([100.0, 1500.0, 2000.0])
}

pub fn map_float_string_price_test() {
  let float_prices = ["100.50", "1500.60", "2000.80"]

  float_prices
  |> list.map(importer.map_string_price)
  |> should.equal([100.5, 1500.6, 2000.8])
}
