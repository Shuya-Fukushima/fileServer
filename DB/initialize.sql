-- ロール作成
CREATE ROLE file_server WITH LOGIN PASSWORD 'file2026';
ALTER ROLE file_server WITH CREATEDB CREATEROLE;

-- DB作成
CREATE DATABASE filedb WITH OWNER file_server ENCODING UTF8;

-- スキーマ作成
CREATE SCHEMA file_server;

-- テーブル作成
-- ファイルテーブル
CREATE TABLE file_server.file (
    file_id BIGINT PRIMARY KEY,
    public_id UUID UNIQUE NOT NULL,
    type_code CHAR(1) NOT NULL DEFAULT 'F',
    name VARCHAR(255) NOT NULL,
    physical_name VARCHAR(255) NOT NULL,
    parent_id BIGINT,
    size BIGINT,
    extension CHAR(2),
    created_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE file_server.file IS 'ファイル';
COMMENT ON COLUMN file_server.file.file_id IS 'ファイルID';
COMMENT ON COLUMN file_server.file.public_id IS 'ファイル識別子';
COMMENT ON COLUMN file_server.file.type_code IS '種別 : F:ファイル, D:フォルダ';
COMMENT ON COLUMN file_server.file.name IS '論理名';
COMMENT ON COLUMN file_server.file.physical_name IS '物理名';
COMMENT ON COLUMN file_server.file.parent_id IS '親フォルダID : ファイルID';
COMMENT ON COLUMN file_server.file.size IS 'ファイルサイズ';
COMMENT ON COLUMN file_server.file.extension IS '拡張子 : 拡張子マスタから変換して格納する。';
COMMENT ON COLUMN file_server.file.created_at IS '作成日';
COMMENT ON COLUMN file_server.file.updated_at IS '更新日';

-- 拡張子マスタテーブル
CREATE TABLE file_server.extension_master (
    extension_id SERIAL PRIMARY KEY,
    extension VARCHAR(20) NOT NULL UNIQUE,
    is_image BOOLEAN DEFAULT FALSE,
    is_binary BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP(0) WITHOUT TIME ZONE,
    updated_at TIMESTAMP(0) WITHOUT TIME ZONE
);

COMMENT ON TABLE file_server.extension_master IS '拡張子マスタ';
COMMENT ON COLUMN file_server.extension_master.extension_id IS '内部ID';
COMMENT ON COLUMN file_server.extension_master.extension IS '拡張子 : ドットなし、小文字';
COMMENT ON COLUMN file_server.extension_master.is_image IS '画像フラグ';
COMMENT ON COLUMN file_server.extension_master.is_binary IS 'バイナリフラグ';
COMMENT ON COLUMN file_server.extension_master.is_active IS '有効フラグ';
COMMENT ON COLUMN file_server.extension_master.created_at IS '作成日';
COMMENT ON COLUMN file_server.extension_master.updated_at IS '更新日';

-- 初期データ
INSERT 
INTO file_server.file( 
    public_id                                   -- ファイル識別子
    , type_code                                 -- 種別
    , name                                      -- 論理名
    , physical_name                             -- 物理名
    , created_at                                -- 作成日
    , updated_at                                -- 更新日
) 
VALUES ( 
    gen_random_uuid()                           -- ファイル識別子
    , 'D'                                       -- 種別
    , '.'                                       -- 論理名
    , 'root'                                    -- 物理名
    , CURRENT_TIMESTAMP                         -- 作成日
    , CURRENT_TIMESTAMP                         -- 更新日
);

INSERT INTO file_server.extension_master (extension, is_image, is_binary) VALUES
-- 画像ファイル (is_image: true, is_binary: true)
('jpg',  true,  true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('jpeg', true,  true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('png',  true,  true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('gif',  true,  true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('svg',  true,  false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP), -- SVGはXMLベースのテキスト形式
('webp', true,  true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 文書・オフィスファイル (is_image: false, is_binary: true)
('pdf',  false, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('docx', false, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('xlsx', false, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('pptx', false, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- テキスト・設定ファイル (is_image: false, is_binary: false)
('txt',  false, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('csv',  false, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('json', false, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('xml',  false, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('md',   false, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('sql',  false, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 圧縮・バイナリファイル (is_image: false, is_binary: true)
('zip',  false, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('7z',   false, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('tar',  false, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('gz',   false, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('exe',  false, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- シーケンス作成
CREATE SEQUENCE file_server.file_id_seq AS BIGINT START 1 CYCLE;

-- トリガーファンクション
CREATE OR REPLACE FUNCTION file_server.ensure_file_id()
RETURNS TRIGGER AS $$
DECLARE
    first_val BIGINT;
    new_val BIGINT;
    exists_flag BOOLEAN;
BEGIN
    -- IDが未指定、または既にテーブルに存在するIDが渡されたかチェック
    IF NEW.file_id IS NOT NULL THEN
        SELECT EXISTS(SELECT 1 FROM file WHERE file_id = NEW.file_id) INTO exists_flag;
    ELSE
        exists_flag := TRUE; -- NULLの場合は採番が必要
    END IF;

    -- 重複がある、またはIDがNULLの場合のループ採番
    IF exists_flag THEN
        -- 最初の1個目を取得し、開始地点として記録
        new_val := nextval('file_id_seq');
        first_val := new_val;

        LOOP
            -- 生成した値がまだ使われていないか確認
            SELECT EXISTS(SELECT 1 FROM file WHERE file_id = new_val) INTO exists_flag;
            IF NOT exists_flag THEN
                NEW.file_id := new_val;
                RETURN NEW;
            END IF;

            -- 次の値を生成
            new_val := nextval('file_id_seq');

            -- 一周して開始地点に戻ってきたら、空きがないと判断してエラー
            IF new_val = first_val THEN
                RAISE EXCEPTION 'ID採番エラー: テーブルが満杯です。利用可能なIDが見つかりませんでした。';
            END IF;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- トリガー登録
CREATE TRIGGER check_file_id
BEFORE INSERT ON file_server.file
FOR EACH ROW
EXECUTE FUNCTION file_server.ensure_file_id();