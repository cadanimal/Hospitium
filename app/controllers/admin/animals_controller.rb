class Admin::AnimalsController < Admin::ApplicationController
  load_and_authorize_resource
  include PublicActivity::StoreController
  
  respond_to :html, :json, :csv, :js
  
  def index
    if !params[:archived_view]
      @archived_condition = {archived: false}
    end
    @search = Animal.select('animals.name,
                              animals.microchip,
                              animals.birthday,
                              animals.id,
                              animals.status_id,
                              animals.animal_color_id,
                              animals.animal_sex_id,
                              animals.species_id,
                              animals.spay_neuter_id,
                              animals.updated_at,
                              animals.image,
                              animals.image_file_name,
                              animals.image_updated_at,
                              animals.organization_id,
                              animals.created_at,
                              animals.updated_at').
                    includes(:animal_color, :animal_sex, :species, :status, :organization, :spay_neuter).
                    organization(current_user).
                    where(@archived_condition).
                    search(params[:q])
    @animals = @search.result.paginate(:page => params[:page], :per_page => 10).order("name ASC")
    
    @presenter = Admin::Animals::IndexPresenter.new(current_user)
    
    respond_with(@animals) do |format|
      format.html
      format.csv { render :csv => Animal.includes(:animal_color, :animal_sex, :species, :status, :organization, :spay_neuter, :biter).organization(current_user).all,
                          :filename => 'animals' }
    end
  end

  def show
    @animal = Animal.includes(:animal_color, :animal_sex, :species, :status, :organization, :spay_neuter, :shelter, :shots).find(params[:id])
    if @animal.documents.blank?
      @animal.documents.build
    end
    @presenter = Admin::Animals::ShowPresenter.new(current_user, @animal)
    respond_with(@animal)
  end

  def new
    @animal = Animal.new
    @presenter = Admin::Animals::NewPresenter.new(current_user)
    
    respond_with(@animal)
  end

  def edit
    redirect_to admin_animal_path(params[:id])
  end

  def create
    @animal = current_user.organization.animals.new(animal_params)
    if @animal.save
      $statsd.increment 'animal.created'
      flash[:notice] = 'Animal was successfully created.'
    else
      flash[:error] = 'Animal was not successfully created.'
    end
    
    respond_with(@animal, :location => admin_animal_path(@animal))
  end
  
  def update
    @animal = Animal.find(params[:id])
    @animal.update_attributes(animal_params)
    $statsd.increment 'animal.updated'
    respond_with(@animal, :location => admin_animal_path(@animal)) 
  end

  def destroy
    @animal = Animal.find(params[:id])
    @animal.destroy
    $statsd.increment 'animal.deleted'
    flash[:notice] = 'Successfully destroyed animal.'
    
    respond_with(@animal, :location => admin_animals_path)
  end
  
  def duplicate
    new_record = Animal.find(params[:id]).dup
    if new_record.save
      $statsd.increment 'animal.duplicated'
      flash[:notice] = 'Successfully duplicated.'
    else
      flash[:error] = 'There was a problem duplicating.'
    end
    
    redirect_to :back
  end
  
  def cage_card
    @animal = Animal.includes(:animal_color, :animal_sex, :species, :status, :organization, :spay_neuter, :shelter).find(params[:id])

    respond_with(@animal) do |format|
      format.html {render :action => "cage_card", :layout => "cage_card"}
      format.xml  { render :xml => @animal }
    end
  end
  
  def qr_code
    @animal = Animal.includes(:animal_color, :animal_sex, :species, :status, :organization, :spay_neuter, :shelter).find(params[:id])

    respond_to do |format|
      format.html {render :action => "qr_code", :layout => "qr_code"}
      format.svg { render :qrcode => "
        #{@animal.name}
        #{@animal.species_name}
        ----
        #{@animal.organization_name} 
        #{view_context.number_to_phone(@animal.organization_phone_number, :area_code => true) unless @animal.organization_phone_number.blank?}
        #{@animal.organization_address unless @animal.organization_address.blank?}
        #{@animal.organization_city unless @animal.organization_city.blank?} #{@animal.organization_state unless @animal.organization_state.blank?} #{@animal.organization_zip_code unless @animal.organization_zip_code.blank?}", :level => :h, :unit => 6 }
    end
  end

  def add_image
    @animal = Animal.find(params[:id])
    if @animal.update_attributes(params[:animal])
      flash[:notice] = 'Successfully added image.'
    else
      flash[:error] = @animal.errors.messages.first
    end
    redirect_to admin_animal_path(@animal)
  end

  private
    def animal_params
      # this is terrible
      params[:animal][:birthday] = Chronic.parse(params[:animal][:birthday]) if params[:animal][:birthday]
      params[:animal][:date_of_intake] = Chronic.parse(params[:animal][:date_of_intake]) if params[:animal][:date_of_intake]
      params[:animal][:date_of_well_check] = Chronic.parse(params[:animal][:date_of_well_check]) if params[:animal][:date_of_well_check]
      params[:animal][:adopted_date] = Chronic.parse(params[:animal][:adopted_date]) if params[:animal][:adopted_date]
      params[:animal][:deceased] = Chronic.parse(params[:animal][:deceased]) if params[:animal][:deceased]

      params.require(:animal).permit(:name, :previous_name, :species_id, :special_needs, :diet, :date_of_intake, :date_of_well_check, :shelter_id, :deceased, 
        :deceased_reason, :adopted_date, :animal_color_id, :image, :second_image, :third_image, :fourth_image, :public, :birthday, :animal_sex_id, :spay_neuter_id,
        :biter_id, :status_id, :video_embed, :microchip, :archived)
    end
end
