package com.shiku.file.util;

import java.util.List;
import java.util.stream.Collectors;

import com.atilika.kuromoji.ipadic.Token;
import com.atilika.kuromoji.ipadic.Tokenizer;
import com.ibm.icu.text.Transliterator;

public class JapaneseToRomaji {

	// 漢字 -> カナ 用の形態素解析器
	private static final Tokenizer TOKENIZER = new Tokenizer();

	// カナ -> ローマ字 変換用
	private static final Transliterator TO_ROMAN = Transliterator.getInstance("Any-Latin");

	// 全角 -> 半角 変換用
	private static final Transliterator TO_HALF = Transliterator.getInstance("Fullwidth-Halfwidth");

	/**
	 * 日本語の論理名を半角英数の物理名に変換します
	 * 例: 「顧客 氏名１」 -> "kokyaku_shimei_1"
	 * @param logicalName 変換対象日本語文字列
	 * @return
	 */
	public static String generate(String logicalName) {
		if (logicalName == null || logicalName.isEmpty())
			return "";

		// 形態素解析で分かち書きし、読みを取得して連結（単語間をアンダースコアで繋ぐ）
		List<Token> tokens = TOKENIZER.tokenize(logicalName);
		String phoneticName = tokens.stream()
				.map(token -> {
					String reading = token.getReading();
					// 読みがない（英数字など）場合は元の文字を使用
					return "*".equals(reading) ? token.getSurface() : reading;
				})
				.collect(Collectors.joining("_"));

		// ローマ字変換
		String roman = TO_ROMAN.transliterate(phoneticName);

		// 全角英数字を半角に変換
		String half = TO_HALF.transliterate(roman);

		// 仕上げ（小文字化、不正な記号の除去、連続するアンダースコアの整理）
		return half.toLowerCase()
				.replaceAll("[^a-z0-9_]", "") // 英数字とアンダースコア以外を削除
				.replaceAll("_{2,}", "_") // 連続するアンダースコアを1つに
				.replaceAll("^_|_$", ""); // 先頭と末尾のアンダースコアを削除
	}
}