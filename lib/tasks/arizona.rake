namespace "arizona" do
  task :load_benefits => :environment do
    Arizona::LoadBenefits.perform
  end

  task :prep_caches => :environment do
    Arizona::PrepCaches.perform
  end

  task :load_customers => :environment do
    Arizona::LoadCustomers.perform
  end

  task :load_aztec_customers => :environment do
    Arizona::LoadAztecCustomers.perform
  end
  task :prep_customer_cache => :environment do
    Arizona::PrepCustomerCache.perform
  end

  task :load_jobs_clients => :environment do
    Arizona::LoadJobsClients.perform
  end

   task :load_case_comp => :environment do
    Arizona::LoadCaseComp.perform
   end

   task :load_client_basic => :environment do
    Arizona::LoadClientBasic.perform
   end

  task :link_docs_to_customers => :environment do
    Arizona::LinkDocsToCustomers.perform
  end
  task :load_jobs_comments => :environment do
    Arizona::LoadJobsComments.perform
  end
end
