from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session

from app import models, schemas
from app.database import engine, SessionLocal, Base

from typing import List


Base.metadata.create_all(bind=engine)

app = FastAPI()


# Dependency: create session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI"}


@app.post("/cars")
def create_car(car: schemas.CarCreate, db: Session = Depends(get_db)):
    new_car = models.Car(brand=car.brand, model=car.model)
    db.add(new_car)
    db.commit()
    db.refresh(new_car)
    return new_car


@app.delete("/cars/{car_id}")
def delete_car(car_id: int, db: Session = Depends(get_db)):
    car = db.query(models.Car).filter(models.Car.id == car_id).first()
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")
    db.delete(car)
    db.commit()
    return {"detail": "Car deleted"}


@app.get("/cars", response_model=List[schemas.Car])
def get_all_cars(db: Session = Depends(get_db)):
    return db.query(models.Car).all()
