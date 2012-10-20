class PhotosController < ApplicationController
  def index
    @photos = Photo.paginate(page: params[:page], per_page: 25)
  end

  def show
    @photo = Photo.find(params[:id])
  end

  def new
    @photo = Photo.new
  end

  def create
    # raise params.to_yaml
    @photo = Photo.new(params[:photo])
    @entry = Entry.find(@photo.entry_id)

    respond_to do |format|
      if @photo.save
        format.html {
          render :json => [@photo.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: [@photo.to_jq_upload].to_json, status: :created, location: @photo }
        format.js
      else
        format.html { redirect_to :back }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @photo = Photo.find(params[:id])
  end

  def update
    @photo = Photo.find(params[:id])
    if @photo.update_attributes(params[:photo])
      redirect_to @photo, :notice  => "Successfully updated photo."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    redirect_to :back, :notice => "Successfully destroyed photo."
  end
end
