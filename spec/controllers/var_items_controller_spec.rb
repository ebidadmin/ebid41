require File.dirname(__FILE__) + '/../spec_helper'

describe VarItemsController do
  fixtures :all
  render_views

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    get :show, :id => VarItem.first
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    VarItem.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    VarItem.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(var_item_url(assigns[:var_item]))
  end

  it "edit action should render edit template" do
    get :edit, :id => VarItem.first
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    VarItem.any_instance.stubs(:valid?).returns(false)
    put :update, :id => VarItem.first
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    VarItem.any_instance.stubs(:valid?).returns(true)
    put :update, :id => VarItem.first
    response.should redirect_to(var_item_url(assigns[:var_item]))
  end

  it "destroy action should destroy model and redirect to index action" do
    var_item = VarItem.first
    delete :destroy, :id => var_item
    response.should redirect_to(var_items_url)
    VarItem.exists?(var_item.id).should be_false
  end
end
