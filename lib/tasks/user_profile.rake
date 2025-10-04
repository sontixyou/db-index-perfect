namespace :user_profile do
  desc "Create user_profiles for existing users with randomized career text from 1000 companies"
  task create_profiles: :environment do
    # Generate 1000 company career histories
    def generate_company_careers
      companies = [
        "テクノロジーソリューションズ", "クラウドイノベーション", "デジタルシステムズ", "ソフトウェアファクトリー", "アドバンステクノロジー",
        "サイバーエージェンシー", "ネットワークソリューション", "データサイエンス", "インフォメーションテクノロジー", "グローバルシステムズ",
        "エンタープライズソフトウェア", "モバイルアプリケーションズ", "クラウドコンピューティング", "アジャイルデベロップメント", "オープンソースラボ",
        "ビッグデータアナリティクス", "AIイノベーション", "ブロックチェーンテック", "IoTソリューションズ", "セキュリティシステムズ"
      ]

      roles = [
        "Webアプリケーション開発", "フロントエンド開発", "バックエンド開発", "インフラ構築", "データベース設計",
        "機械学習エンジニアリング", "モバイルアプリ開発", "DevOps", "SRE", "セキュリティエンジニアリング",
        "プロダクトマネジメント", "テクニカルリード", "アーキテクト", "UI/UXデザイン", "QAエンジニアリング"
      ]

      projects = [
        "ECサイトのリニューアル", "決済システムの開発", "在庫管理システムの構築", "顧客管理CRMの開発", "予約管理システムの実装",
        "レコメンデーションエンジンの開発", "リアルタイムチャットシステム", "データ分析基盤の構築", "マイクロサービス化プロジェクト", "API基盤の整備",
        "検索システムの最適化", "コンテンツ配信プラットフォーム", "ログ解析システム", "監視基盤の構築", "CI/CDパイプラインの整備",
        "セキュリティ監査システム", "モバイルアプリのリリース", "管理画面の刷新", "パフォーマンス改善プロジェクト", "レガシーシステムのリプレイス"
      ]

      techs = [
        ["Ruby on Rails", "React", "PostgreSQL", "AWS"], ["Django", "Vue.js", "MySQL", "GCP"], ["Node.js", "Angular", "MongoDB", "Azure"],
        ["Spring Boot", "Next.js", "Oracle", "AWS"], ["Laravel", "Nuxt.js", "Redis", "GCP"], ["Flask", "Svelte", "DynamoDB", "AWS"],
        ["Express.js", "React Native", "Elasticsearch", "Kubernetes"], ["FastAPI", "Flutter", "Firebase", "GCP"], ["ASP.NET", "Blazor", "SQL Server", "Azure"],
        ["Go", "TypeScript", "Cassandra", "Docker"], ["Rust", "Remix", "Neo4j", "Terraform"], ["Scala", "Elm", "CouchDB", "Ansible"],
        ["Kotlin", "Solid.js", "InfluxDB", "Jenkins"], ["Swift", "Qwik", "TimescaleDB", "CircleCI"], ["PHP", "Astro", "MariaDB", "GitHub Actions"]
      ]

      achievements = [
        "月間100万PVのサービスを無停止でリリース", "レスポンスタイムを50%改善", "コスト削減率30%を達成", "チーム立ち上げから3ヶ月でMVPリリース",
        "セキュリティ監査で脆弱性ゼロを達成", "テストカバレッジ90%以上を実現", "デプロイ頻度を週1回から1日10回に向上", "障害発生率を80%削減",
        "新規機能開発のリードタイムを半減", "技術ブログで月間10万PVを獲得", "社内勉強会を主催し技術力向上に貢献", "OSSへの貢献でコントリビューター認定",
        "アーキテクチャ刷新により開発速度2倍向上", "パフォーマンス改善でサーバーコスト40%削減", "新人教育プログラムを策定し離職率低下に貢献"
      ]

      1000.times.map do |i|
        company = "株式会社#{companies.sample}#{i / 50 + 1}"
        year_start = rand(2010..2020)
        year_end = year_start + rand(2..4)
        role = roles.sample
        project = projects.sample
        tech_stack = techs.sample
        achievement = achievements.sample

        <<~CAREER
          【#{year_start}年#{rand(1..12)}月〜#{year_end}年#{rand(1..12)}月：#{company}】
          #{role}エンジニアとして#{project}プロジェクトに参画。#{tech_stack[0]}と#{tech_stack[1]}を中心とした技術スタックで、#{tech_stack[2]}によるデータ管理と#{tech_stack[3]}によるインフラ構築を実施しました。特に#{project}においては、要件定義から設計、実装、テスト、運用まで一貫して担当し、#{achievement}という成果を上げました。この経験を通じて、#{tech_stack[0]}のベストプラクティスやパフォーマンスチューニング、セキュリティ対策の知識を深めることができました。また、#{rand(3..8)}名のチームで開発を進める中で、コードレビューや技術的な意思決定、後輩エンジニアの育成にも携わり、チーム全体の技術力向上に貢献しました。プロジェクトの成功により、社内表彰を受け、次期プロジェクトのテックリード候補として推薦されました。開発プロセスにおいては、アジャイル開発手法を採用し、2週間スプリントでのイテレーション開発を実践。デイリースタンドアップ、スプリントプランニング、レトロスペクティブなどのスクラムイベントを通じて、継続的な改善活動を推進しました。技術的負債の返済にも積極的に取り組み、レガシーコードのリファクタリングやテストコードの整備を進めることで、保守性と拡張性の高いシステムを実現しました。
        CAREER
      end
    end

    # puts "Generating 1000 company career histories..."
    company_careers = generate_company_careers
    # puts "Generated #{company_careers.size} career histories"

    total_users = User.count
    # puts "Total users: #{total_users}"
    puts "Starting user_profile creation..."

    created_count = 0
    skipped_count = 0

    User.find_in_batches(batch_size: 1000) do |users|
      user_profiles = []

      users.each do |user|
        # Skip if user_profile already exists
        next if UserProfile.exists?(user_id: user.id)

        # Randomly select 4 career histories and combine them
        selected_careers = company_careers.sample(4)
        combined_career = selected_careers.join("\n\n")

        user_profiles << {
          user_id: user.id,
          career: combined_career,
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      if user_profiles.any?
        UserProfile.insert_all(user_profiles)
        created_count += user_profiles.size
        puts "Created #{created_count} user_profiles..."
      else
        skipped_count += users.size
      end
    end

    puts "Completed!"
    # puts "Created: #{created_count} user_profiles"
    # puts "Skipped: #{skipped_count} users (already have profiles)"
  end
end
