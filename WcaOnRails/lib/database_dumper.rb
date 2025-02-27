# frozen_string_literal: true

module DatabaseDumper
  JOIN_WHERE_VISIBLE_COMP = "JOIN Competitions ON Competitions.id=competition_id WHERE showAtAll=1"
  DUMP_TIMESTAMP_NAME = "developer_dump_exported_at"
  VISIBLE_ACTIVITY_IDS = "SELECT A.id FROM schedule_activities AS A JOIN venue_rooms ON (venue_rooms.id = holder_id AND holder_type='VenueRoom') JOIN competition_venues ON competition_venues.id = competition_venue_id #{JOIN_WHERE_VISIBLE_COMP}"
                         .freeze

  def self.actions_to_column_sanitizers(columns_by_action)
    {}.tap do |column_sanitizers|
      columns_by_action.each do |action, columns|
        case action
        when :copy, :db_default
          columns.each do |column|
            column_sanitizers[column] = action
          end
        when :fake_values
          columns.each do |column, column_sanitizer|
            column_sanitizers[column] = column_sanitizer
          end
        else
          raise "Unrecognized action #{action}"
        end
      end
    end
  end

  TABLE_SANITIZERS = {
    "Competitions" => {
      where_clause: "WHERE showAtAll = TRUE",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          name
          name_reason
          cityName
          countryId
          information
          year
          month
          day
          endYear
          endMonth
          endDay
          start_date
          end_date
          venue
          venueAddress
          venueDetails
          external_website
          cellName
          showAtAll
          latitude
          longitude
          confirmed_at
          contact
          registration_open
          registration_close
          enable_donations
          use_wca_registration
          external_registration_page
          competitor_limit_enabled
          competitor_limit
          competitor_limit_reason
          guests_enabled
          guests_per_registration_limit
          results_posted_at
          results_submitted_at
          results_nag_sent_at
          registration_reminder_sent_at
          generate_website
          announced_at
          base_entry_fee_lowest_denomination
          currency_code
          extra_registration_requirements
          created_at
          updated_at
          on_the_spot_registration
          on_the_spot_entry_fee_lowest_denomination
          refund_policy_percent
          refund_policy_limit_date
          guests_entry_fee_lowest_denomination
          guest_entry_status
          early_puzzle_submission
          early_puzzle_submission_reason
          qualification_results
          qualification_results_reason
          event_restrictions
          event_restrictions_reason
          announced_by
          results_posted_by
          main_event_id
          cancelled_at
          cancelled_by
          waiting_list_deadline_date
          event_change_deadline_date
          allow_registration_edits
          allow_registration_self_delete_after_acceptance
          competition_series_id
          use_wca_live_for_scoretaking
          allow_registration_without_qualification
        ),
        db_default: %w(
          connected_stripe_account_id
        ),
        fake_values: {
          "remarks" => "'remarks to the board here'",
        },
      ),
    }.freeze,
    "CompetitionsMedia" => {
      where_clause: "WHERE status = 'accepted'",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          competitionId
          type
          text
          uri
          timestampSubmitted
          timestampDecided
          status
        ),
        fake_values: {
          "submitterName" => "'mr. media submitter'",
          "submitterComment" => "'a comment about this media'",
          "submitterEmail" => "'mediasubmitter@example.com'",
        },
      ),
    }.freeze,
    "ConciseAverageResults" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          average
          continentId
          countryId
          day
          eventId
          id
          month
          personId
          valueAndId
          year
        ),
      ),
    }.freeze,
    "ConciseSingleResults" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          best
          continentId
          countryId
          day
          eventId
          id
          month
          personId
          valueAndId
          year
        ),
      ),
    }.freeze,
    "Continents" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          latitude
          longitude
          name
          recordName
          zoom
        ),
      ),
    }.freeze,
    "Countries" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          continentId
          iso2
          name
        ),
      ),
    }.freeze,
    "Events" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          cellName
          format
          name
          rank
        ),
      ),
    }.freeze,
    "Formats" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          expected_solve_count
          name
          sort_by
          sort_by_second
          trim_fastest_n
          trim_slowest_n
        ),
      ),
    }.freeze,
    "InboxPersons" => :skip_all_rows,
    "InboxResults" => :skip_all_rows,
    "Persons" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          comments
          countryId
          gender
          name
          rails_id
          subId
        ),
        db_default: %w(
          comments
          incorrect_wca_id_claim_count
        ),
        fake_values: {
          "year" => "1954",
          "month" => "12",
          "day" => "4",
        },
      ),
    }.freeze,
    "RanksAverage" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          best
          continentRank
          countryRank
          eventId
          personId
          worldRank
        ),
      ),
    }.freeze,
    "RanksSingle" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          best
          continentRank
          countryRank
          eventId
          personId
          worldRank
        ),
      ),
    }.freeze,
    "Results" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          average
          best
          competitionId
          countryId
          eventId
          formatId
          personId
          personName
          pos
          regionalAverageRecord
          regionalSingleRecord
          roundTypeId
          updated_at
          value1
          value2
          value3
          value4
          value5
        ),
      ),
    }.freeze,
    "rounds" => {
      where_clause: "JOIN competition_events ON competition_events.id = competition_event_id #{JOIN_WHERE_VISIBLE_COMP}",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          competition_event_id
          format_id
          total_number_of_rounds
          number
          time_limit
          cutoff
          advancement_condition
          scramble_set_count
          round_results
          created_at
          updated_at
          old_type
        ),
      ),
    }.freeze,
    "RoundTypes" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          cellName
          final
          name
          rank
        ),
      ),
    }.freeze,
    "Scrambles" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          competitionId
          eventId
          groupId
          isExtra
          roundTypeId
          scramble
          scrambleId
          scrambleNum
        ),
      ),
    }.freeze,
    "active_storage_attachments" => :skip_all_rows,
    "active_storage_blobs" => :skip_all_rows,
    "active_storage_variant_records" => :skip_all_rows,
    "ar_internal_metadata" => :skip_all_rows,
    "competition_delegates" => {
      where_clause: JOIN_WHERE_VISIBLE_COMP,
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          competition_id
          created_at
          delegate_id
          receive_registration_emails
          updated_at
        ),
      ),
    }.freeze,
    "competition_trainee_delegates" => {
      where_clause: JOIN_WHERE_VISIBLE_COMP,
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          competition_id
          created_at
          trainee_delegate_id
          receive_registration_emails
          updated_at
        ),
      ),
    }.freeze,
    "competition_events" => {
      where_clause: JOIN_WHERE_VISIBLE_COMP,
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          competition_id
          event_id
          fee_lowest_denomination
          qualification
        ),
      ),
    }.freeze,
    "competition_organizers" => {
      where_clause: JOIN_WHERE_VISIBLE_COMP,
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          competition_id
          created_at
          organizer_id
          receive_registration_emails
          updated_at
        ),
      ),
    }.freeze,
    "competition_series" => {
      # One Series can be associated with many competitions, so any JOIN will inherently produce duplicates. Get rid of them by using GROUP BY.
      where_clause: "LEFT JOIN Competitions ON Competitions.competition_series_id=competition_series.id WHERE showAtAll=1 GROUP BY competition_series.id",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          wcif_id
          name
          short_name
          created_at
          updated_at
        ),
      ),
    }.freeze,
    "competition_tabs" => {
      where_clause: JOIN_WHERE_VISIBLE_COMP,
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          competition_id
          content
          display_order
          name
        ),
      ),
    }.freeze,
    "competition_venues" => {
      where_clause: JOIN_WHERE_VISIBLE_COMP,
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          competition_id
          wcif_id
          name
          country_iso2
          latitude_microdegrees
          longitude_microdegrees
          timezone_id
          created_at
          updated_at
        ),
      ),
    }.freeze,
    "venue_rooms" => {
      where_clause: "JOIN competition_venues ON competition_venues.id = competition_venue_id #{JOIN_WHERE_VISIBLE_COMP}",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          competition_venue_id
          wcif_id
          name
          color
          created_at
          updated_at
        ),
      ),
    }.freeze,
    "schedule_activities" => {
      where_clause: "WHERE (holder_type=\"ScheduleActivity\" AND holder_id IN (#{VISIBLE_ACTIVITY_IDS}) or id in (#{VISIBLE_ACTIVITY_IDS}))",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          holder_type
          holder_id
          wcif_id
          name
          activity_code
          start_time
          end_time
          scramble_set_id
          created_at
          updated_at
        ),
      ),
    }.freeze,
    "completed_jobs" => :skip_all_rows,
    "delayed_jobs" => :skip_all_rows,
    "delegate_reports" => {
      where_clause: JOIN_WHERE_VISIBLE_COMP,
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          competition_id
          created_at
          updated_at
        ),
        db_default: %w(
          equipment
          venue
          organization
          schedule_url
          incidents
          remarks
          discussion_url
          posted_by_user_id
          posted_at
          nag_sent_at
          wrc_feedback_requested
          wrc_incidents
          wdc_feedback_requested
          wdc_incidents
          wrc_primary_user_id
          wrc_secondary_user_id
          reminder_sent_at
        ),
      ),
    }.freeze,
    "oauth_access_grants" => :skip_all_rows,
    "oauth_access_tokens" => :skip_all_rows,
    "oauth_applications" => :skip_all_rows,
    "archive_registrations" => :skip_all_rows,
    "archive_phpbb3_forums" => :skip_all_rows,
    "archive_phpbb3_posts" => :skip_all_rows,
    "archive_phpbb3_topics" => :skip_all_rows,
    "archive_phpbb3_users" => :skip_all_rows,
    "poll_options" => :skip_all_rows,
    "polls" => :skip_all_rows,
    "posts" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          author_id
          body
          created_at
          slug
          sticky
          unstick_at
          title
          updated_at
          show_on_homepage
        ),
      ),
    }.freeze,
    "post_tags" => {
      where_clause: "JOIN posts ON posts.id=post_tags.post_id",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          post_id
          tag
        ),
      ),
    }.freeze,
    "preferred_formats" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          event_id
          format_id
          ranking
        ),
      ),
    }.freeze,
    "rails_persons" => :skip_all_rows,
    "regional_organizations" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          name
          country
          website
          start_date
          end_date
          created_at
          updated_at
        ),
        fake_values: {
          "email" => "'contact@regional-organization.org'",
          "address" => "'Street and Number, City, State, Postal code, Country'",
          "directors_and_officers" => "'Directors and Officers'",
          "area_description" => "'Area'",
          "past_and_current_activities" => "'Activities'",
          "future_plans" => "'Plans'",
          "extra_information" => "'Extra information'",
        },
      ),
    }.freeze,
    "registration_competition_events" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          competition_event_id
          registration_id
        ),
      ),
    }.freeze,
    "registration_payments" => :skip_all_rows,
    "registrations" => {
      where_clause: JOIN_WHERE_VISIBLE_COMP,
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          accepted_at
          accepted_by
          competition_id
          created_at
          deleted_at
          deleted_by
          guests
          updated_at
          user_id
          roles
        ),
        db_default: %w(ip),
        fake_values: {
          "comments" => "''", # Can't use :db_default here because comments does not have a default value.
        },
      ),
    }.freeze,
    "sanity_checks" => :skip_all_rows,
    "sanity_check_categories" => :skip_all_rows,
    "sanity_check_exclusions" => :skip_all_rows,
    "cached_results" => :skip_all_rows,
    "schema_migrations" => :skip_all_rows, # This is populated when loading our schema dump
    "starburst_announcement_views" => :skip_all_rows,
    "starburst_announcements" => :skip_all_rows,
    "team_members" => {
      where_clause: "JOIN teams ON teams.id=team_id WHERE NOT teams.hidden",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          created_at
          end_date
          start_date
          team_id
          team_leader
          updated_at
          user_id
          team_senior_member
        ),
      ),
    }.freeze,
    "teams" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          created_at
          friendly_id
          email
          hidden
          updated_at
        ),
      ),
    }.freeze,
    "user_preferred_events" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          event_id
          user_id
        ),
      ),
    }.freeze,
    "users" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          avatar
          competition_notifications_enabled
          confirmed_at
          country_iso2
          created_at
          current_sign_in_at
          delegate_id_to_handle_wca_id_claim
          delegate_status
          gender
          last_sign_in_at
          name
          region
          registration_notifications_enabled
          results_notifications_enabled
          saved_avatar_crop_h
          saved_avatar_crop_w
          saved_avatar_crop_x
          saved_avatar_crop_y
          saved_pending_avatar_crop_h
          saved_pending_avatar_crop_w
          saved_pending_avatar_crop_x
          saved_pending_avatar_crop_y
          senior_delegate_id unconfirmed_wca_id
          updated_at
          wca_id
          receive_delegate_reports
          dummy_account
        ),
        db_default: %w(
          confirmation_sent_at
          confirmation_token
          consumed_timestep
          cookies_acknowledged
          current_sign_in_ip
          encrypted_otp_secret
          encrypted_otp_secret_iv
          encrypted_otp_secret_salt
          encrypted_password
          last_sign_in_ip
          otp_backup_codes
          otp_required_for_login
          pending_avatar
          preferred_locale
          remember_created_at
          reset_password_sent_at
          reset_password_token
          sign_in_count
          unconfirmed_email
          session_validity_token
          otp_secret
        ),
        fake_values: {
          "dob" => "'1954-12-04'",
          "email" => "CONCAT(id, '@worldcubeassociation.org')",
        },
      ),
    }.freeze,
    "locations" => :skip_all_rows,
    "incidents" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(id title public_summary digest_worthy resolved_at digest_sent_at created_at updated_at),
        db_default: %w(private_description private_wrc_decision),
      ),
    }.freeze,
    "incident_competitions" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(id incident_id competition_id),
        db_default: %w(comments),
      ),
    }.freeze,
    "incident_tags" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(id incident_id tag),
      ),
    }.freeze,
    "vote_options" => :skip_all_rows,
    "votes" => :skip_all_rows,
    # We have seen MySQL full table errors when trying to copy the entire linkings table.
    # Fortunately, it is a not really important table, so we can simply skip all its rows.
    "linkings" => :skip_all_rows,
    "timestamps" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          name
          date
        ),
      ),
    }.freeze,
    "championships" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          competition_id
          championship_type
        ),
      ),
    }.freeze,
    "eligible_country_iso2s_for_championship" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          championship_type
          eligible_country_iso2
        ),
      ),
    }.freeze,
    "wcif_extensions" => :skip_all_rows,
    "assignments" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          registration_id
          schedule_activity_id
          station_number
          assignment_code
        ),
      ),
    }.freeze,
    "stripe_charges" => :skip_all_rows,
    "uploaded_jsons" => :skip_all_rows,
    "bookmarked_competitions" => {
      where_clause: JOIN_WHERE_VISIBLE_COMP,
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          user_id
          competition_id
        ),
      ),
    }.freeze,
    "country_bands" => {
      where_clause: "",
      column_sanitizers: actions_to_column_sanitizers(
        copy: %w(
          id
          number
          iso2
        ),
      ),
    }.freeze,
  }.freeze

  def self.development_dump(dump_filename)
    dump_db_name = "wca_development_db_dump"

    LogTask.log_task "Creating temporary database '#{dump_db_name}'" do
      ActiveRecord::Base.connection.execute("DROP DATABASE IF EXISTS #{dump_db_name}")
      ActiveRecord::Base.connection.execute("CREATE DATABASE #{dump_db_name} DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci")
      self.mysql("SOURCE #{Rails.root.join('db', 'structure.sql')}", dump_db_name)
    end

    LogTask.log_task "Populating sanitized tables in '#{dump_db_name}'" do
      TABLE_SANITIZERS.each do |table_name, table_sanitizer|
        next if table_sanitizer == :skip_all_rows

        column_sanitizers = table_sanitizer[:column_sanitizers].select do |column_name, column_sanitizer|
          column_sanitizer != :db_default
        end

        column_expressions = column_sanitizers.map do |column_name, column_sanitizer|
          column_sanitizer == :copy ? "#{table_name}.#{column_name}" : "#{column_sanitizer} as #{ActiveRecord::Base.connection.quote_column_name column_name}"
        end.join(", ")

        # Some column names like "rank" are reserved keywords starting mysql 8.0 and require quoting.
        quoted_column_list = column_sanitizers.keys.map { |column_name| ActiveRecord::Base.connection.quote_column_name column_name }.join(", ")

        populate_table_sql = "INSERT INTO #{dump_db_name}.#{table_name} (#{quoted_column_list}) SELECT #{column_expressions} FROM #{table_name} #{table_sanitizer[:where_clause]}"
        ActiveRecord::Base.connection.execute(populate_table_sql)
      end

      ActiveRecord::Base.connection.execute("INSERT INTO #{dump_db_name}.timestamps (name, date) VALUES ('#{DUMP_TIMESTAMP_NAME}', UTC_TIMESTAMP())")
    end

    LogTask.log_task "Dumping '#{dump_db_name}' to '#{dump_filename}'" do
      self.mysqldump(dump_db_name, dump_filename)
    end
  ensure
    ActiveRecord::Base.connection.execute("DROP DATABASE IF EXISTS #{dump_db_name}")
  end

  def self.mysql_cli_creds
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    "--user=#{config[:username]} --password=#{config[:password] || "''"} --port=#{config[:port]} --host=#{config[:host]}"
  end

  def self.mysql(command, database = nil)
    bash!("mysql #{self.mysql_cli_creds} #{database} -e '#{command}' #{filter_out_mysql_warning}")
  end

  def self.mysqldump(db_name, dest_filename)
    # Use --set-gtid-purged=OFF to avoid having `SET @@GLOBAL.gtid_purged` and `SET @@SESSION.SQL_LOG_BIN`
    # in the resulting dump file, as setting these require additional parmissions
    # making it troublesome to import the dump into a managed databases like the staging one.
    bash!("mysqldump --set-gtid-purged=OFF #{self.mysql_cli_creds} #{db_name} -r #{dest_filename} #{filter_out_mysql_warning}")
    bash!("sed -i 's_^/\\*!50013 DEFINER.*__' #{dest_filename}")
  end

  def self.filter_out_mysql_warning
    '2>&1 | grep -v "[Warning] Using a password on the command line interface can be insecure." || true'
  end
end

# See https://julialang.org/blog/2012/03/shelling-out-sucks
def bash!(cmd)
  cmd = "set -o pipefail && #{cmd}"
  system("bash -c #{cmd.shellescape}") || raise("Error while running '#{cmd}' (#{$CHILD_STATUS})")
end
