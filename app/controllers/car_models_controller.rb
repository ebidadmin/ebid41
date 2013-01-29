class CarModelsController < ApplicationController
  def index
    @car_models = CarModel.includes(:car_brand, :entries).page(params[:page]).per_page(20)
  end

  def show
    @car_model = CarModel.find(params[:id], include: [:car_variants => [:entries => :user]])
  end

  def new
    @car_model = CarModel.new(creator_id: current_user.id)
  end

  def create
    @car_model = CarModel.new(params[:car_model])
    if @car_model.save
      redirect_to @car_model, :notice => "Successfully created car model."
    else
      render :action => 'new'
    end
  end

  def edit
    store_location
    @car_model = CarModel.find(params[:id])
  end

  def update
    @car_model = CarModel.find(params[:id])
    if @car_model.update_attributes(params[:car_model])
      redirect_back_or_default @car_model.car_brand
    else
      render :action => 'edit'
    end
  end

  def destroy
    store_location
    @car_model = CarModel.find(params[:id])
    @car_model.destroy
    redirect_back_or_default @car_model.car_brand
  end

  def selected
    @car_variants = CarVariant.where(car_model_id: params[:id]).order(:name)
  end
end
