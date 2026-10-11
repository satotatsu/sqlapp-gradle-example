1. DB2 / HSQLDB / H2
-- 事前準備：一時テーブル（セッション終了で自動削除）
DECLARE LOCAL TEMPORARY TABLE temp_users (
    name VARCHAR(50)
) ON COMMIT PRESERVE ROWS;

-- ★一括UPSERT ＆ 新規ID回収クエリ（Javaからは executeQuery() で実行）
SELECT id, name FROM FINAL TABLE (
    INSERT INTO users (name)
    SELECT t.name FROM temp_users t
    WHERE NOT EXISTS (
        SELECT 1 FROM users u WHERE u.name = t.name
    )
);
-- ※ 既存データの「更新（UPDATE）」も同時に行いたい場合は、別途以下の標準MERGEをバッチ実行します
MERGE INTO users AS t
USING temp_users AS s ON (t.name = s.name)
WHEN MATCHED THEN UPDATE SET t.updated_at = CURRENT_TIMESTAMP;

-----------------------------------------------------------------------------------
Postgres
-- 事前準備：一時テーブル
CREATE TEMP TABLE temp_users (name VARCHAR(50));

-- ★一括UPSERT ＆ 全ID回収（Javaからは executeQuery() で実行）
INSERT INTO users (name)
SELECT name FROM temp_users
ON CONFLICT (name) -- 衝突判定するユニーク制約カラム
DO UPDATE SET updated_at = CURRENT_TIMESTAMP -- 衝突時は更新
RETURNING id, name; -- 新規・更新問わず、対象になった全行のIDをResultSetとして返却！

-----------------------------------------------------------------------------------
Microsoft SQL Server
-- 事前準備：一時テーブル（#を頭につける）
CREATE TABLE #temp_users (name VARCHAR(50));

-- ★一括UPSERT ＆ 全ID回収（Javaからは executeQuery() で実行）
MERGE INTO users AS t
USING #temp_users AS s ON (t.name = s.name)
WHEN MATCHED THEN
    UPDATE SET t.updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (name) VALUES (s.name)
OUTPUT INSERTED.id, INSERTED.name; -- 挿入・更新されたIDをまとめてResultSetで返却

-----------------------------------------------------------------------------------
4. Oracle Database
Oracleの MERGE 文は RETURNING 句をサポートしていません。そのため、一時テーブルからPL/SQLのバルク処理機能（BULK COLLECT / FORALL）を使ってデータを回し、IDを回収します（Javaからは CallableStatement や匿名ブロックで実行）。

DECLARE
    -- 一時テーブルのデータを載せる配列
    TYPE t_name_list IS TABLE OF temp_users.name%TYPE;
    l_names t_name_list;
    
    -- 生成されたIDを回収する配列
    TYPE t_id_list IS TABLE OF users.id%TYPE;
    l_new_ids t_id_list;
BEGIN
    -- 1. 一時テーブルからデータを一括取得
    SELECT name BULK COLLECT INTO l_names FROM temp_users;

    -- 2. FORALLによる高速一括UPSERT ＆ ID回収
    -- (※OracleのFORALL内ではMERGE+RETURNINGが使えないため、一度INSERTを試し、
    --  例外が起きたらUPDATEに回すか、事前に手動で振り分けるのが一般的です)
    FORALL i IN 1..l_names.COUNT
        INSERT INTO users (name) VALUES (l_names(i))
        -- 新規挿入が成功した行のIDをl_new_idsにガバッと回収
        RETURNING id BULK COLLECT INTO l_new_ids; 
END;
/
String plsql = 
    "DECLARE " +
    "    TYPE t_name_list IS TABLE OF temp_users.name%TYPE; " +
    "    l_names t_name_list; " +
    "BEGIN " +
    "    SELECT name BULK COLLECT INTO l_names FROM temp_users; " +
    "    -- (中略) -- " +
    "END;";

try (Statement stmt = conn.createStatement()) {
    stmt.execute(plsql); // その場でコンパイル＆実行される
}
-----------------------------------------------------------------------------------
5. Firebird
FirebirdはOracleと似ており、MERGE 単体ではIDを返せません。代わりに EXECUTE BLOCK という使い捨てのストアド処理をJavaから動的に投げて、SUSPEND キーワードでResultSetのように行を返却します。
EXECUTE BLOCK
RETURNS (out_id INT, out_name VARCHAR(50))
AS
DECLARE variable var_name VARCHAR(50);
BEGIN
    -- 一時テーブルから1行ずつ回す（内部的には高速に処理される）
    FOR SELECT name FROM temp_users INTO :var_name DO
    BEGIN
        -- UPSERT処理
        UPDATE OR INSERT INTO users (name) VALUES (:var_name)
        MATCHING (name)
        RETURNING id, name INTO :out_id, :out_name;
        
        -- Java側に1行分のResultSetとして出力
        SUSPEND; 
    END
END
-----------------------------------------------------------------------------------
MySQL
-- 一時テーブルの作成（セッション終了で自動消滅）
CREATE TEMPORARY TABLE temp_users (
    tmp_key VARCHAR(36),  -- Java側で振ったUUIDを入れるカラム
    name VARCHAR(50)
);
INSERT INTO users (name, tmp_key)
SELECT name, tmp_key FROM temp_users
ON DUPLICATE KEY UPDATE 
    -- 既に同じnameがある場合は、tmp_keyを最新のUUIDで上書きしてマーキングする
    users.tmp_key = VALUES(tmp_key),
    users.updated_at = NOW();
-----------------------------------------------------------------------------------
MySQL / SAP HANA / Spanner / Vertica を使う場合：
事前採番しろ


| アプローチ対象 | RDB | 特徴とID回収の流れ |
| ---------- | ---------- | ---------- |
|  【Aパターン】SQL一発で完結型 | PostgreSQL SQLServer | MERGE や INSERT...ON CONFLICT の一括処理のおまけ（RETURNING / OUTPUT）として自動でIDが返ってくる。一時テーブルとの後続JOINすら不要で最も高速。| 
| 【Bパターン】一時テーブル結合型| HSQLDB H2 MySQL | 一括UPSERTを実行した直後に、「本番テーブル」と「一時テーブル」をユニーク制約のカラムで JOIN してIDを一括回収する。| 
| 【Cパターン】DBスクリプト型| Oracle FirebirdSQL | 単体の一括処理ではIDが取れない（または制約が強い）ため、DB側の匿名スクリプト（PL/SQL等）の中で一括処理とID回収を同時に行う。| 
| 【Dパターン】アーキテクチャ分離型| SAP HANA Cloud SpannerVertica| 分散・DWH環境のため、そもそも「IDENTITYのリアルタイム回収」が非推奨。事前にSEQUENCEでIDをJava側で全件確保してからバッチを投げるのが定石。| 


1. 【Bパターン】 DB2 / HSQLDB / H2
-- 事前準備：一時テーブル（セッション終了で自動削除）
DECLARE LOCAL TEMPORARY TABLE temp_users (
    name VARCHAR(50)
) ON COMMIT PRESERVE ROWS;

-- ★一括UPSERT ＆ 新規ID回収クエリ（Javaからは executeQuery() で実行）
SELECT id, name FROM FINAL TABLE (
    INSERT INTO users (name)
    SELECT t.name FROM temp_users t
    WHERE NOT EXISTS (
        SELECT 1 FROM users u WHERE u.name = t.name
    )
);
-- ※ 既存データの「更新（UPDATE）」も同時に行いたい場合は、別途以下の標準MERGEをバッチ実行します
MERGE INTO users AS t
USING temp_users AS s ON (t.name = s.name)
WHEN MATCHED THEN UPDATE SET t.updated_at = CURRENT_TIMESTAMP;


1. 【Bパターン】 MySQL（Bパターン：一時テーブル結合型）
-- ① 一括UPSERT（MySQL独自構文）
INSERT INTO users (name)
SELECT name FROM temp_users
ON DUPLICATE KEY UPDATE updated_at = NOW();

-- ② ★ID一括回収（Javaからは executeQuery() で実行）
SELECT u.id, u.name 
FROM users u
INNER JOIN temp_users t ON u.name = t.name;

PostgreSQL（Aパターン：SQL一発完結型）
ユニーク制約があることで、ON CONFLICT が100%の力を発揮します。JOINすら不要で、新規挿入・既存更新されたすべてのIDが1つのResultSetで返ってきます。
-- ★一括UPSERT ＆ 全ID回収（Javaからは executeQuery() で実行）
INSERT INTO users (name)
SELECT name FROM temp_users
ON CONFLICT (name) -- ←ここに対象のユニーク制約カラムを指定
DO UPDATE SET updated_at = CURRENT_TIMESTAMP
RETURNING id, name; -- これだけで新規・更新すべてのIDがまとめて返る

Microsoft SQL Server（Aパターン：SQL一発完結型）
標準の MERGE を使いつつ、OUTPUT 句で新規ID（INSERTED.id）も既存ID（DELETED.id または INSERTED.id）もすべて一網打尽にできます。
-- ★一括UPSERT ＆ 全ID回収（Javaからは executeQuery() で実行）
MERGE INTO users AS t
USING temp_users AS s ON (t.name = s.name)
WHEN MATCHED THEN
    UPDATE SET t.updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (name) VALUES (s.name)
OUTPUT INSERTED.id, INSERTED.name; -- 処理対象になった全IDをResultSetで返却

5. Oracle Database（Cパターン：DBスクリプト型）
Oracleの場合、ユニーク制約があっても MERGE 文単体からIDを直接回収することはできません。しかし、PL/SQLの匿名ブロックを使えば、ユニーク制約を利用して「一括UPSERT」と「ID一括回収（SELECT）」を1往復の通信でシームレスに処理できます。
-- Javaからはこの匿名ブロック全体をそのまま送信する
DECLARE
    -- IDと名前を格納するコレクション型を定義
    TYPE t_rec IS RECORD (id users.id%TYPE, name users.name%TYPE);
    TYPE t_list IS TABLE OF t_rec;
    l_results t_list;
BEGIN
    -- ① 一括UPSERT（標準MERGEを実行）
    MERGE INTO users t
    USING temp_users s ON (t.name = s.name)
    WHEN MATCHED THEN
        UPDATE SET t.updated_at = SYSDATE
    WHEN NOT MATCHED THEN
        INSERT (name) VALUES (s.name);

    -- ② ユニーク制約を使って、処理したデータのIDを一括回収して変数に入れる
    -- (Java側でRefCursorなどを介して受け取るか、このまま処理を完結させる)
    SELECT u.id, u.name 
    BULK COLLECT INTO l_results
    FROM users u
    INNER JOIN temp_users t ON u.name = t.name;
END;
/

SAP HANA（Dパターン：TEMPテーブル型）
CREATE LOCAL TEMPORARY TABLE #temp_users (
    name VARCHAR(50)
);

-- データの流し込み（IDENTITYがないため、ノーブレーキで高速にバッチ挿入可能）
INSERT INTO #temp_users (name) VALUES (?);
-- ユニーク制約（name）をベースに、一括でマージ（UPSERT）を実行
UPSERT users (name, updated_at)
SELECT name, CURRENT_TIMESTAMP FROM #temp_users;

-- ★このクエリを Java から executeQuery() で実行し、ResultSet としてIDを一括回収する
SELECT 
    u.id, 
    u.name 
FROM users u
INNER JOIN #temp_users t ON u.name = t.name;

VerticaでのバルクUPSERT ＆ ID回収手順
-- 一時テーブルの作成
CREATE LOCAL TEMP TABLE temp_users (
    name VARCHAR(50)
) ON COMMIT PRESERVE ROWS;
-- 本番用のシーケンス（事前に1度だけ作成しておく）
-- CREATE SEQUENCE user_id_seq;

-- ★一括MERGE（新規挿入時のみシーケンスからIDを切り出す）
MERGE INTO users AS t
USING temp_users AS s ON (t.name = s.name)
WHEN MATCHED THEN
    UPDATE SET t.updated_at = NOW()
WHEN NOT MATCHED THEN
    INSERT (id, name, updated_at) VALUES (NEXTVAL('user_id_seq'), s.name, NOW());
-- ★このクエリをJavaの executeQuery() で実行して一括回収
SELECT u.id, u.name 
FROM users u
INNER JOIN temp_users t ON u.name = t.name;
