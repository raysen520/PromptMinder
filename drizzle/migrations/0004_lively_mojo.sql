CREATE TABLE "agent_conversations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"team_id" uuid,
	"user_id" text NOT NULL,
	"title" text DEFAULT '新对话' NOT NULL,
	"session_id" text NOT NULL,
	"last_message_at" timestamp with time zone DEFAULT now() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "agent_messages" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"conversation_id" uuid NOT NULL,
	"role" text NOT NULL,
	"content" text NOT NULL,
	"tool_calls" jsonb,
	"tool_results" jsonb,
	"sequence" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"metadata" jsonb
);
--> statement-breakpoint
CREATE TABLE "cli_tokens" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" text NOT NULL,
	"name" text NOT NULL,
	"token_hash" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT timezone('utc', now()) NOT NULL,
	"last_used_at" timestamp with time zone,
	"revoked_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "in_app_notifications" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"team_id" uuid,
	"user_id" text NOT NULL,
	"type" text NOT NULL,
	"title" text NOT NULL,
	"body" text NOT NULL,
	"entity_type" text,
	"entity_id" text,
	"is_read" boolean DEFAULT false NOT NULL,
	"read_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "prompt_change_comment_mentions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"comment_id" uuid NOT NULL,
	"mentioned_user_id" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "unique_prompt_change_comment_mention" UNIQUE("comment_id","mentioned_user_id")
);
--> statement-breakpoint
CREATE TABLE "prompt_change_comments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"change_request_id" uuid NOT NULL,
	"team_id" uuid NOT NULL,
	"author_user_id" text NOT NULL,
	"content" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "chk_prompt_change_comment_not_empty" CHECK (char_length(trim("prompt_change_comments"."content")) > 0)
);
--> statement-breakpoint
CREATE TABLE "prompt_change_requests" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"team_id" uuid NOT NULL,
	"lineage_id" uuid NOT NULL,
	"base_prompt_id" uuid,
	"request_type" text NOT NULL,
	"proposed_title" text NOT NULL,
	"proposed_content" text NOT NULL,
	"proposed_description" text,
	"proposed_tags" text,
	"proposed_version" text,
	"proposed_project_id" uuid,
	"status" text DEFAULT 'pending' NOT NULL,
	"submitter_user_id" text NOT NULL,
	"reviewed_by_user_id" text,
	"review_note" text,
	"reviewed_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "chk_prompt_change_request_type" CHECK ("prompt_change_requests"."request_type" IN ('create_prompt', 'create_version')),
	CONSTRAINT "chk_prompt_change_request_status" CHECK ("prompt_change_requests"."status" IN ('pending', 'approved', 'rejected', 'withdrawn'))
);
--> statement-breakpoint
CREATE TABLE "prompt_lineages" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"team_id" uuid,
	"name" text NOT NULL,
	"created_by" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "chk_prompt_lineage_name_not_empty" CHECK (char_length(trim("prompt_lineages"."name")) > 0)
);
--> statement-breakpoint
CREATE TABLE "prompt_subscriptions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"team_id" uuid NOT NULL,
	"lineage_id" uuid NOT NULL,
	"user_id" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "unique_prompt_subscription" UNIQUE("team_id","lineage_id","user_id")
);
--> statement-breakpoint
CREATE TABLE "prompt_workflow_events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"team_id" uuid NOT NULL,
	"lineage_id" uuid NOT NULL,
	"change_request_id" uuid,
	"event_type" text NOT NULL,
	"actor_user_id" text NOT NULL,
	"payload_json" jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "public_tags" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"description" text,
	"category" text DEFAULT 'general' NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_by" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "public_tags_name_unique" UNIQUE("name"),
	CONSTRAINT "chk_public_tag_name_not_empty" CHECK (char_length(trim("public_tags"."name")) > 0)
);
--> statement-breakpoint
ALTER TABLE "prompts" ADD COLUMN "lineage_id" uuid NOT NULL;--> statement-breakpoint
ALTER TABLE "teams" ADD COLUMN "approval_enabled" boolean DEFAULT true NOT NULL;--> statement-breakpoint
ALTER TABLE "in_app_notifications" ADD CONSTRAINT "in_app_notifications_team_id_teams_id_fk" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "prompt_change_comment_mentions" ADD CONSTRAINT "prompt_change_comment_mentions_comment_id_prompt_change_comments_id_fk" FOREIGN KEY ("comment_id") REFERENCES "public"."prompt_change_comments"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "prompt_change_comments" ADD CONSTRAINT "prompt_change_comments_change_request_id_prompt_change_requests_id_fk" FOREIGN KEY ("change_request_id") REFERENCES "public"."prompt_change_requests"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "prompt_change_comments" ADD CONSTRAINT "prompt_change_comments_team_id_teams_id_fk" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "prompt_change_requests" ADD CONSTRAINT "prompt_change_requests_team_id_teams_id_fk" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "prompt_change_requests" ADD CONSTRAINT "prompt_change_requests_lineage_id_prompt_lineages_id_fk" FOREIGN KEY ("lineage_id") REFERENCES "public"."prompt_lineages"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "prompt_change_requests" ADD CONSTRAINT "prompt_change_requests_base_prompt_id_prompts_id_fk" FOREIGN KEY ("base_prompt_id") REFERENCES "public"."prompts"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "prompt_lineages" ADD CONSTRAINT "prompt_lineages_team_id_teams_id_fk" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "prompt_subscriptions" ADD CONSTRAINT "prompt_subscriptions_team_id_teams_id_fk" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "prompt_subscriptions" ADD CONSTRAINT "prompt_subscriptions_lineage_id_prompt_lineages_id_fk" FOREIGN KEY ("lineage_id") REFERENCES "public"."prompt_lineages"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "prompt_workflow_events" ADD CONSTRAINT "prompt_workflow_events_team_id_teams_id_fk" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "prompt_workflow_events" ADD CONSTRAINT "prompt_workflow_events_lineage_id_prompt_lineages_id_fk" FOREIGN KEY ("lineage_id") REFERENCES "public"."prompt_lineages"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "prompt_workflow_events" ADD CONSTRAINT "prompt_workflow_events_change_request_id_prompt_change_requests_id_fk" FOREIGN KEY ("change_request_id") REFERENCES "public"."prompt_change_requests"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_agent_conversations_user_id" ON "agent_conversations" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_agent_conversations_team_id" ON "agent_conversations" USING btree ("team_id");--> statement-breakpoint
CREATE INDEX "idx_agent_conversations_session_id" ON "agent_conversations" USING btree ("session_id");--> statement-breakpoint
CREATE INDEX "idx_agent_conversations_last_message_at" ON "agent_conversations" USING btree ("last_message_at" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "idx_agent_conversations_created_at" ON "agent_conversations" USING btree ("created_at" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "idx_agent_messages_conversation_id" ON "agent_messages" USING btree ("conversation_id");--> statement-breakpoint
CREATE INDEX "idx_agent_messages_created_at" ON "agent_messages" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "idx_agent_messages_conversation_sequence" ON "agent_messages" USING btree ("conversation_id","sequence");--> statement-breakpoint
CREATE UNIQUE INDEX "cli_tokens_token_hash_idx" ON "cli_tokens" USING btree ("token_hash");--> statement-breakpoint
CREATE INDEX "cli_tokens_user_id_idx" ON "cli_tokens" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "cli_tokens_revoked_at_idx" ON "cli_tokens" USING btree ("revoked_at");--> statement-breakpoint
CREATE INDEX "idx_in_app_notifications_user_id" ON "in_app_notifications" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_in_app_notifications_team_id" ON "in_app_notifications" USING btree ("team_id");--> statement-breakpoint
CREATE INDEX "idx_in_app_notifications_is_read" ON "in_app_notifications" USING btree ("is_read");--> statement-breakpoint
CREATE INDEX "idx_in_app_notifications_created_at" ON "in_app_notifications" USING btree ("created_at" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "idx_prompt_change_comment_mentions_comment_id" ON "prompt_change_comment_mentions" USING btree ("comment_id");--> statement-breakpoint
CREATE INDEX "idx_prompt_change_comment_mentions_user_id" ON "prompt_change_comment_mentions" USING btree ("mentioned_user_id");--> statement-breakpoint
CREATE INDEX "idx_prompt_change_comments_change_request_id" ON "prompt_change_comments" USING btree ("change_request_id");--> statement-breakpoint
CREATE INDEX "idx_prompt_change_comments_team_id" ON "prompt_change_comments" USING btree ("team_id");--> statement-breakpoint
CREATE INDEX "idx_prompt_change_comments_created_at" ON "prompt_change_comments" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "idx_prompt_change_requests_team_id" ON "prompt_change_requests" USING btree ("team_id");--> statement-breakpoint
CREATE INDEX "idx_prompt_change_requests_lineage_id" ON "prompt_change_requests" USING btree ("lineage_id");--> statement-breakpoint
CREATE INDEX "idx_prompt_change_requests_status" ON "prompt_change_requests" USING btree ("status");--> statement-breakpoint
CREATE INDEX "idx_prompt_change_requests_submitter" ON "prompt_change_requests" USING btree ("submitter_user_id");--> statement-breakpoint
CREATE INDEX "idx_prompt_change_requests_created_at" ON "prompt_change_requests" USING btree ("created_at" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "idx_prompt_lineages_team_id" ON "prompt_lineages" USING btree ("team_id");--> statement-breakpoint
CREATE INDEX "idx_prompt_lineages_team_name" ON "prompt_lineages" USING btree ("team_id",lower("name"));--> statement-breakpoint
CREATE INDEX "idx_prompt_subscriptions_team_id" ON "prompt_subscriptions" USING btree ("team_id");--> statement-breakpoint
CREATE INDEX "idx_prompt_subscriptions_lineage_id" ON "prompt_subscriptions" USING btree ("lineage_id");--> statement-breakpoint
CREATE INDEX "idx_prompt_subscriptions_user_id" ON "prompt_subscriptions" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_prompt_workflow_events_team_id" ON "prompt_workflow_events" USING btree ("team_id");--> statement-breakpoint
CREATE INDEX "idx_prompt_workflow_events_lineage_id" ON "prompt_workflow_events" USING btree ("lineage_id");--> statement-breakpoint
CREATE INDEX "idx_prompt_workflow_events_change_request_id" ON "prompt_workflow_events" USING btree ("change_request_id");--> statement-breakpoint
CREATE INDEX "idx_prompt_workflow_events_created_at" ON "prompt_workflow_events" USING btree ("created_at" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "idx_public_tags_category" ON "public_tags" USING btree ("category");--> statement-breakpoint
CREATE INDEX "idx_public_tags_is_active" ON "public_tags" USING btree ("is_active");--> statement-breakpoint
CREATE INDEX "idx_public_tags_sort_order" ON "public_tags" USING btree ("sort_order");--> statement-breakpoint
ALTER TABLE "prompts" ADD CONSTRAINT "prompts_lineage_id_prompt_lineages_id_fk" FOREIGN KEY ("lineage_id") REFERENCES "public"."prompt_lineages"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_prompts_lineage_id" ON "prompts" USING btree ("lineage_id");