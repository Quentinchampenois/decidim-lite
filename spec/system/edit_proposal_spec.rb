# frozen_string_literal: true

require "spec_helper"

describe "User edits proposals", type: :system do
  include_context "with a component"
  let!(:organization) { create :organization, available_locales: [:en] }
  let!(:participatory_process) { create :participatory_process, :with_steps, organization: organization }
  let(:manifest_name) { "proposals" }
  let(:manifest) { Decidim.find_component_manifest(manifest_name) }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:settings) { nil }
  let(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           :with_attachments_allowed,
           manifest: manifest,
           participatory_space: participatory_process,
           settings: settings)
  end
  let(:organization_traits) { [] }

  let(:proposal_title) { "This is my great proposal to change the world" }
  let(:proposal_body) { "This is my great proposal to change the world" }

  def visit_component
    if organization_traits&.include?(:secure_context)
      switch_to_secure_context_host
    else
      switch_to_host(organization.host)
    end
    page.visit main_component_path(component)
  end

  context "when user has proposal" do
    let!(:proposal) { create(:proposal, users: [user], component: component) }
    let(:settings) { { require_category: false, require_scope: false, attachments_allowed: true } }

    before do
      login_as user, scope: :user
      visit_component
      click_link translated(proposal.title)
      click_link "Edit proposal"
      fill_in :proposal_title, with: proposal_title
      fill_in :proposal_body, with: proposal_body
    end

    it "can be edited" do
      click_button "Send"
      expect(page).to have_content("Proposal successfully updated")
      expect(Decidim::Proposals::Proposal.last.title["en"]).to eq(proposal_title)
      expect(Decidim::Proposals::Proposal.last.body["en"]).to eq(proposal_body)
    end

    context "when uploading a file", processing_uploads_for: Decidim::AttachmentUploader do
      it "can add image" do
        dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city.jpeg"))
        click_button "Send"
        expect(page).to have_content("Proposal successfully updated")
      end

      it "can add images" do
        dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city.jpeg"))
        click_button "Send"
        click_link "Edit proposal"
        dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city2.jpeg"), remove_before: true)
        click_button "Send"
        expect(page).to have_content("Proposal successfully updated")
        expect(Decidim::Proposals::Proposal.last.attachments.count).to eq(1)
      end

      it "can add pdf document" do
        dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("Exampledocument.pdf"))
        click_button "Send"
        expect(page).to have_content("Proposal successfully updated")
      end
    end

    context "when proposal has attachment" do
      let!(:proposal) { create(:proposal, users: [user], component: component) }
      let!(:attachment) { create(:attachment, title: { "en" => filename }, file: file, attached_to: proposal, weight: 0) }

      context "when proposal has pdf attachment" do
        let(:filename) { "Exampledocument.pdf" }
        let(:file) { Decidim::Dev.test_file(filename, "application/pdf") }

        before do
          login_as user, scope: :user
          visit_component
          click_link translated(proposal.title)
        end

        it "can remove document attachment" do
          click_link "Edit proposal"

          click_button "Edit documents"
          within ".upload-modal" do
            click_button "Remove"
            click_button "Save"
          end

          click_button "Send"
          expect(page).to have_content("Proposal successfully updated.")
          expect(page).not_to have_content("Documents ")
          expect(page).not_to have_link(filename)
          expect(Decidim::Proposals::Proposal.find(proposal.id).attachments).to be_empty
        end
      end

      context "when proposal has card image" do
        let(:filename) { "city.jpeg" }
        let(:file) { Decidim::Dev.test_file(filename, "image/jpeg") }

        before do
          login_as user, scope: :user

          settings = component.settings
          settings.comments_enabled = false
          component.update(settings: settings)

          visit_component
          click_link translated(proposal.title), match: :first
        end

        it "can remove card image" do
          click_link "Edit proposal"

          click_button "Edit documents"
          within ".upload-modal" do
            click_button "Remove"
            click_button "Save"
          end

          click_button "Send"
          expect(page).to have_content("Proposal successfully updated.")
          expect(page).not_to have_content("Images")
          expect(page).not_to have_link(filename)
          expect(Decidim::Proposals::Proposal.find(proposal.id).attachments).to be_empty
        end

        it "can set new card image" do
          click_link "Edit proposal"
          dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city2.jpeg"), remove_before: true)

          click_button "Send"
          expect(page).to have_content("Proposal successfully updated.")
          expect(page).to have_content("Images")

          created_proposal = Decidim::Proposals::Proposal.find(proposal.id)
          expect(created_proposal.attachments.count).to eq(1)
          expect(created_proposal.photos.count).to eq(1)
          expect(created_proposal.photos.first.title["en"]).to eq("city2.jpeg")
        end
      end
    end

    context "when proposal has card image and document image" do
      let!(:proposal) { create(:proposal, users: [user], component: component) }

      let!(:card_image) { create(:attachment, title: { "en" => filename }, file: file, attached_to: proposal, weight: 0) }
      let(:filename) { "city.jpeg" }
      let(:file) { Decidim::Dev.test_file(filename, "image/jpeg") }

      let!(:document) { create(:attachment, title: { "en" => filename2 }, file: file2, attached_to: proposal, weight: 1) }
      let(:filename2) { "city2.jpeg" }
      let(:file2) { Decidim::Dev.test_file(filename2, "image/jpeg") }

      before do
        login_as user, scope: :user
        visit_component
        click_link translated(proposal.title), match: :first
      end

      it "attachments are in different sections" do
        click_link "Edit proposal"
        page.execute_script "window.scrollBy(0,10000)"
        expect(page).to have_selector(".attachment-details[data-filename='#{filename}']")
        expect(page).to have_selector(".attachment-details[data-filename='#{filename2}']")
      end
    end
  end
end
