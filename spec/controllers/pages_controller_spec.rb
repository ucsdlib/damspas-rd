require 'spec_helper'

describe PagesController do
  describe "public" do
    describe "GET index" do
      it "assigns all pages as @pages" do
        @page = create(:page)
        get :index
        expect(Page.count).to eq(1)
      end
    end

    describe "GET view" do
      it "assigns the requested page as @page" do
        @page = create(:page)
        get :view, params: { id: @page.slug }
        expect(assigns(:page)).to eq(@page)
      end
    end
  end

  describe "authenticated" do
    let(:user) { create(:editor) }

    before do
      sign_in user
    end

    describe "GET new" do
      it "assigns a new page as @page" do
        get :new
        expect(assigns(:page)).to be_a_new(Page)
      end
    end

    describe "GET edit" do
      it "assigns the requested page as @page" do
        @page = create(:page)
        get :edit, params: { id: @page.to_param }
        expect(assigns(:page)).to eq(@page)
      end
    end

    describe "POST create" do
      context "with valid params" do
        before do
          post :create, params: { page: attributes_for(:page, slug: "page_slug") }
        end

        it "creates a new Page" do
          expect(Page.count).to eq(1)
        end

        it "redirects to the created page" do
          expect(response).to redirect_to action: :index
        end
      end

      context "with invalid params" do
        before do
          post :create, params: { page: attributes_for(:page, slug: "invalid value") }
        end

        it "sets @page" do
          expect(assigns(:page)).to be_instance_of(Page)
        end

        it "does not create the invoice" do
          expect(Page.count).to eq(0)
        end

        it "re-renders the 'new' template" do
          expect(response).to render_template :new
        end
      end
    end

    describe "PUT update" do
      context "with valid params" do
        before do
          @page = create(:page)
          put :update, params: { id: @page, page: attributes_for(:page, slug: "my_slug") }
          @page.reload
        end

        it "updates the requested page" do
          expect(@page.slug).to eq("my_slug")
        end

        it "redirects to the page" do
          expect(response).to redirect_to action: :edit, id: @page.id
        end
      end

      context "with invalid params" do
        before do
          @page = create(:page)
          put :update, params: { id: @page, page: attributes_for(:page, slug: "invalid value") }
          @page.reload
        end

        it "assigns the page as @page" do
          expect(assigns(:page)).to eq(@page)
        end

        it "re-renders the 'edit' template" do
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do
      before do
        @page = create(:page)
        delete :destroy, params: { id: @page }
      end

      it "redirects to the page index page" do
        expect(response).to redirect_to pages_path
      end

      it "deletes the page" do
        expect(Page.count).to eq(0)
      end
    end
  end
end
