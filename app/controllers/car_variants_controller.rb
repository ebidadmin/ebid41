class CarVariantsController < ApplicationController
  def index
    @car_variants = CarVariant.paginate(page: params[:page], per_page: 20)
  end

  def show
    @car_variant = CarVariant.find(params[:id])
  end

  def new
    @car_variant = CarVariant.new(creator_id: current_user.id)
    @car_models = []
  end

  def create
    @car_variant = CarVariant.new(params[:car_variant])
    if @car_variant.save
      flash[:success] = "Added new variant."
      if can? :access, :all
        redirect_to :back
      else
        redirect_to new_user_entry_path(current_user, variant: @car_variant )
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @car_variant = CarVariant.find(params[:id])
  end

  def update
    @car_variant = CarVariant.find(params[:id])
    if @car_variant.update_attributes(params[:car_variant])
      redirect_to @car_variant, :notice  => "Successfully updated car variant."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @car_variant = CarVariant.find(params[:id])
    @car_variant.destroy
    redirect_to car_variants_url, :notice => "Successfully destroyed car variant."
  end
end
