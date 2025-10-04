# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create users with user_profiles containing ~5000 character career text
10.times do |i|
  user = User.find_or_create_by!(email: "user#{i + 1}@example.com") do |u|
    u.first_name = "太郎#{i + 1}"
    u.last_name = "山田"
  end

  career_text = <<~CAREER
    【職務経歴概要】
    2015年4月に新卒として株式会社テクノロジーソリューションズに入社し、Webアプリケーション開発エンジニアとしてキャリアをスタートしました。入社後の新人研修では、Java、SQL、HTMLなどの基礎技術を学び、その後配属されたECサイト開発プロジェクトにおいて、フロントエンド開発を担当しました。初めての実務では、先輩エンジニアの指導のもと、JavaScript、CSS、HTMLを使用したユーザーインターフェースの実装を行い、レスポンシブデザインやアクセシビリティへの配慮を学びました。

    【2016年〜2018年：バックエンド開発への転換期】
    2年目からは、バックエンド開発へと業務の幅を広げました。Spring FrameworkとMyBatisを用いた業務システムの開発に携わり、RESTful APIの設計・実装、データベース設計、トランザクション制御などの技術を習得しました。特に、在庫管理システムのリプレイス案件では、レガシーシステムからの移行作業を担当し、データ移行スクリプトの作成やパフォーマンスチューニングの経験を積みました。この時期に、SQLのインデックス設計やクエリ最適化の重要性を深く理解し、データベース技術への興味を強めました。

    【2018年〜2020年：リーダー経験とクラウド技術の習得】
    入社4年目には、5名のチームリーダーとして金融機関向けの決済システム開発プロジェクトを任されました。要件定義から基本設計、実装、テスト、リリースまでの一連の工程を管理し、プロジェクトマネジメントのスキルを磨きました。また、この案件ではAWSを採用しており、EC2、RDS、S3、CloudFrontなどのサービスを活用したシステムアーキテクチャの構築に携わりました。Infrastructure as Codeの概念に触れ、Terraformを用いたインフラのコード管理を実践しました。セキュリティ面では、AWS IAMによる権限管理やVPC設計、暗号化技術の実装など、本番環境における堅牢なシステム構築のノウハウを習得しました。

    【2020年〜2022年：モダン技術スタックへの挑戦】
    2020年に株式会社クラウドイノベーションに転職し、より最新の技術スタックを扱う環境でスキルアップを図りました。主にReactとNode.jsを用いたSPA開発に従事し、TypeScript、Redux、Next.jsなどのモダンなフロントエンド技術を実務で活用しました。バックエンドでは、Express.jsやNestJSを使用したマイクロサービスアーキテクチャの設計・開発を経験し、Docker、Kubernetesによるコンテナオーケストレーションの知識を深めました。また、CI/CDパイプラインの構築にも携わり、GitHub Actions、CircleCIを用いた自動テスト・デプロイの仕組みを実装しました。この時期には、アジャイル開発手法を本格的に実践し、スクラムマスターの役割も経験しました。

    【2022年〜現在：フルスタックエンジニアとしての成長】
    現在は、Ruby on RailsとReactを組み合わせたWebアプリケーション開発に従事しています。Rails 7、8の最新機能を活用し、Hotwire（Turbo、Stimulus）による効率的なフロントエンド開発や、Solid Queue、Solid Cacheなどのモダンな機能を実装しています。データベースはMySQLとPostgreSQLの両方を扱い、パフォーマンスチューニングや適切なインデックス設計を行っています。また、GraphQL APIの設計・実装にも携わり、効率的なデータフェッチングの手法を学びました。

    最近では、機械学習モデルを組み込んだレコメンデーション機能の開発にも関わり、PythonとFlaskを用いたAPIサーバーの構築、RailsアプリケーションとのAPI連携を実装しました。技術的な課題解決だけでなく、ビジネス要件の理解やステークホルダーとのコミュニケーションを重視し、技術とビジネスの両面から価値を提供できるエンジニアを目指しています。

    【保有スキル・技術】
    プログラミング言語：Ruby、JavaScript、TypeScript、Python、Java、Go
    フレームワーク：Ruby on Rails、React、Next.js、Vue.js、Node.js、Express.js、NestJS、Spring Boot
    データベース：MySQL、PostgreSQL、Redis、MongoDB
    クラウド・インフラ：AWS（EC2、RDS、S3、Lambda、CloudFront、ECS、EKS）、GCP、Docker、Kubernetes、Terraform
    その他：Git、GitHub Actions、CircleCI、GraphQL、REST API、マイクロサービス、アジャイル開発

    【今後の目標】
    技術的な深さと幅の両方を追求し、システムアーキテクトやテックリードとして、チームや組織の技術的な意思決定をリードできる存在になることを目指しています。また、OSSへの貢献や技術コミュニティでの知見共有を通じて、業界全体の発展に寄与したいと考えています。
  CAREER

  UserProfile.find_or_create_by!(user: user) do |profile|
    profile.career = career_text
  end
end

puts "Created 10 users with user_profiles (career text: ~5000 characters)"
