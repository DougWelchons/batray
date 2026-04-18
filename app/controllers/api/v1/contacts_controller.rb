class Api::V1::ContactsController < Api::V1::BaseController
  before_action :set_contact, only: [ :update, :destroy ]

  def index
    @contractor = @company.contractors.find(params[:contractor_id])
    @contacts = @contractor.contacts
  end

  def create
    @contractor = @company.contractors.find(contact_params[:contractor_id])
    @contact = @contractor.contacts.build(contact_params)

    if @contact.save
      render :show, status: :created
    else
      render json: { errors: @contact.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @contact.update(contact_params.except(:contractor_id))
      render :show
    else
      render json: { errors: @contact.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy
    head :no_content
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(
      :contractor_id,
      :name,
      :email,
      :phone,
      :role
    )
  end
end
