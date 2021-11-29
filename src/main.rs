use pyo3::prelude::*;
use tensorflow::Tensor;

fn main() {
    let gil = Python::acquire_gil();
    let py = gil.python();

    let sys = py.import("sys").unwrap();
    let _ = py.import("google.cloud.storage").unwrap();
    let version :String = sys.getattr("version").unwrap().extract().unwrap();
    println!("Hello python {}", version );

    let tensor = Tensor::new(&[1,2]).with_values(&[1.0,2.0]).unwrap();
    println!("{:?}", tensor );
}
