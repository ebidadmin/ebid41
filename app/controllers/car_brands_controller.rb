class CarBrandsController < ApplicationController
  def index
    @car_brands = CarBrand.all
  end

  def show
    @car_brand = CarBrand.find(params[:id])
  end

  def new
    @car_brand = CarBrand.new
  end

  def create
    @car_brand = CarBrand.new(params[:car_brand])
    if @car_brand.save
      redirect_to @car_brand, :notice => "Successfully created car brand."
    else
      render :action => 'new'
    end
  end

  def edit
    @car_brand = CarBrand.find(params[:id])
  end

  def update
    @car_brand = CarBrand.find(params[:id])
    if @car_brand.update_attributes(params[:car_brand])
      redirect_to @car_brand, :notice  => "Successfully updated car brand."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @car_brand = CarBrand.find(params[:id])
    @car_brand.destroy
    redirect_to car_brands_url, :notice => "Successfully destroyed car brand."
  end

  def selected
    @car_models = CarModel.where(car_brand_id: params[:id]).order(:name)
  end
end
