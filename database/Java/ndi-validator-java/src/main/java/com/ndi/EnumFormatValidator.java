package com.ndi;

import org.everit.json.schema.FormatValidator;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.zip.GZIPInputStream;

/**
 * A very flexible customized format option validator. It allows user to creates
 * format tag that is not present in the Json Schema Official Specification. This validator
 * can be used when we want to restrict an entry to a set of predefined values, but at the same
 * time, when the user has entered another set of value, we want to create suggestions for the user
 * to enter the correct values. It extends the FormatValidator class, which is called by the Everit
 * Validator when it encounters the this user's defined format tag in the schema document
 */
public class EnumFormatValidator implements FormatValidator {

    /**
     * This is a static inner class that can used to construct an instance of EnumFormatValidator.
     */
    public static class Builder {
        private Table table;
        private String formatName;
        private Rules rules;
        private String filePath;
        private TableFormat tableFormat;

        public Builder() {}

        /**
         * @param formatName The name of our customized format tag
         * @return an instance of FormatValidatorBuilder with the field formatName being initialized
         */
        public Builder setFormatTag(String formatName) {
            this.formatName = formatName;
            return this;
        }

        /**
         * @param rules The validation rules: it should be an instance of HashMap. It should contains
         *              at least one keys: 1) "correct", 2) suggestions (which is optional), whose values
         *              need to be an instance of java.util.List. The value of the key "correct" consist of
         *              a list of accepted columns (that is if the user enter an entry that belongs to a entries
         *              in one of the columns, we accept the user's entry), otherwise if the user has entered an
         *              entries in the list of "suggestions" value's column, then the error message will provide
         *              hint that allows user to enter the value in the corrected column
         * @return return an instance of FormatValidatorBuilder with rules being initialized
         */
        public Builder setRules(Rules rules) {
            if (rules.correct.isEmpty()) {
                throw new IllegalArgumentException("You must have at least one column, whose entry will be accepted by the validator");
            }
            this.rules = rules;
            return this;
        }

        /**
         * set the file path of the gzip/txt file
         *
         * @param filePath: the given filepath
         * @return an instance of FormatValidatorBuilder with filePath initialized
         */
        public Builder setFilePath(String filePath) {
            this.filePath = filePath;
            return this;
        }

        public Builder setParserFormat(TableFormat tableFormat) {
            this.tableFormat = tableFormat;
            return this;
        }

        /**
         * Read the gzip file from the given file path, then convert it into an instance of Table
         * object, which can be saved to a specified directory later through calling the saveTo
         * method. This methods assumes that the row of the columns are split by a new line, and
         * the first row should specify the column names. Also make sure that each entry does not
         * contain any character that you use to split each entry in the row, or else the behavior
         * may be undefined
         *
         * @return the FormatValidatorBuilder with the table initialized
         */
        public Builder loadDataGzip() throws IOException {
            if (this.filePath == null || this.rules == null) {
                throw new IllegalArgumentException("requires file path and rules to be non-null");
            }
            String filepath = this.filePath;
            ArrayList<String> secondaryIndices = new ArrayList<>();
            String primaryIndex = null;
            int firstIndex = 0;
            for (String correctColumn : this.rules.correct) {
                if (firstIndex == 0) {
                    primaryIndex = correctColumn;
                    firstIndex = -1;
                    continue;
                }
                secondaryIndices.add(correctColumn);
            }
            secondaryIndices.addAll(this.rules.suggestions);
            try (InputStream fileStream = new FileInputStream(filepath);
                 InputStream gzipStream = new GZIPInputStream(fileStream);
                 Reader decoder = new InputStreamReader(gzipStream, StandardCharsets.UTF_8);
                 BufferedReader reader = new BufferedReader(decoder)) {
                String line = reader.readLine();
                Map<String, Integer> col2Index = this.tableFormat.parseColumns(line);
                this.table = new Table(this.tableFormat.parseLine(line), primaryIndex);
                while (line != null) {
                    table.addRow(this.tableFormat.parseLine(line));
                    line = reader.readLine();
                }
                for (String secondaryIndex : secondaryIndices) {
                    if (this.tableFormat.patterns.get(col2Index.get(secondaryIndex)).entryPattern != null) {
                        table.createIndexMultiValueColumn(secondaryIndex, this.tableFormat.patterns.get(col2Index.get(secondaryIndex)));
                    } else {
                        table.createIndex(secondaryIndex);
                    }
                }
                return this;
            }
        }

        /**
         * Does everything that the loadDataGzip does, except it works for text file instead.
         * Note it is not recommended to use this method since it is slower.
         *
         * @return the FormatValidatorBuilder with the table initialized
         * @throws IOException throw exception when reading file fails
         * @deprecated
         */
        public Builder loadData() throws IOException {
            if (this.filePath == null || this.rules == null) {
                throw new IllegalArgumentException("requires file path and rules to be non-null");
            }
            String filepath = this.filePath;
            ArrayList<String> secondaryIndices = new ArrayList<>();
            String primaryIndex = null;
            int firstIndex = 0;
            for (String correctColumn : this.rules.correct) {
                if (firstIndex == 0) {
                    primaryIndex = correctColumn;
                    firstIndex = -1;
                    continue;
                }
                secondaryIndices.add(correctColumn);
            }
            secondaryIndices.addAll(this.rules.suggestions);
            try (InputStream fileStream = new FileInputStream(filepath);
                 Reader decoder = new InputStreamReader(fileStream, StandardCharsets.UTF_8);
                 BufferedReader reader = new BufferedReader(decoder)) {
                String line = reader.readLine();
                Map<String, Integer> col2Index = this.tableFormat.parseColumns(line);
                this.table = new Table(this.tableFormat.parseLine(line), primaryIndex);
                while (line != null) {
                    table.addRow(this.tableFormat.parseLine(line));
                    line = reader.readLine();
                }
                for (String secondaryIndex : secondaryIndices) {
                    if (this.tableFormat.patterns.get(col2Index.get(secondaryIndex)).entryPattern != null) {
                        table.createIndexMultiValueColumn(secondaryIndex, this.tableFormat.patterns.get(col2Index.get(secondaryIndex)));
                    } else {
                        table.createIndex(secondaryIndex);
                    }
                }
                return this;
            }
        }

        /**
         * build an instance of AdvancedEnumFormatValidator based on the field set
         * in the FormatValidatorBuilder object
         *
         * @return an instance of AdvancedEnumFormatValidator
         */
        public EnumFormatValidator build() {
            return new EnumFormatValidator(this);
        }
    }

    private final String formatName;
    private final Table table;
    private final Rules rules;
    private final String filePath;
    private final TableFormat tableFormat;

    /**
     * Constructor for the AdvancedEnumFormatValidator class. It takes the an instance of
     * FormatValidatorBuilder. FormatValidatorBuilder must contain all field, except the
     * table field. If table is not initialized, it will validate by calling the gzipSearch
     * methods instead of using the methods in the Table class
     *
     */
    private EnumFormatValidator(Builder builder){
        if (builder.formatName == null){
            throw new IllegalArgumentException("require format name");
        }
        if (builder.rules == null || builder.filePath == null){
            if (builder.table == null){
                throw new IllegalArgumentException("require rules, filePath");
            }
        }
        if (builder.table != null) {
            assert builder.rules != null;
            for (String correctColumn : builder.rules.correct){
                if (!builder.table.isColKey(correctColumn)){
                    throw new IllegalArgumentException("Correct columns must come from a real column from the provided table");
                }
            }
            for (String suggestion : builder.rules.suggestions){
                if (!builder.table.isColKey(suggestion)){
                    throw new IllegalArgumentException("Columns that lead to error messages with suggestions must come" +
                            "from one of the columns in the provided table");
                }
            }
        }
        this.formatName = builder.formatName;
        this.table = builder.table;
        this.rules = builder.rules;
        this.filePath = builder.filePath;
        this.tableFormat = builder.tableFormat;
    }

    /**
     * Perform the validation step
     *
     * @param subject   the user input in that json entry
     * @return          List of error messages. The List would be empty if the user's entry
     *                  is valid.
     */
    @Override
    public Optional<String> validate(String subject) {
        if (this.table == null){
            try {
                String result = this.gzipSearch(subject);
                if (result == null){
                    return Optional.empty();
                }
                return Optional.of(result);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        else{
            List<String> correctOptions = new ArrayList<>();
            for (String correctColumn : rules.correct) {
                try {
                    this.table.getEntry(correctColumn, subject);
                    return Optional.empty();
                }
                catch (IllegalArgumentException ignored) {}
            }

            for (String suggestion : this.rules.suggestions) {
                try{
                    this.table.getEntry(suggestion, subject, suggestion);
                    for (String correctColumn : this.rules.correct){
                        correctOptions.addAll(this.table.getEntry(correctColumn, subject, suggestion));
                    }
                    return Optional.of("Entered: " + subject + ". Expected: any one of " + correctOptions);
                }
                catch (IllegalArgumentException ignored){
                }
            }
        }
        return Optional.of("Entered: " + subject + ". Expected: an entry from the columns " + rules.correct);
    }

    /**
     * The name of the user-defined format tag
     *
     * @return  the name of this format tag
     */
    @Override
    public String formatName() {
        return this.formatName;
    }

    /**
     * Perform a one-time linear search for a given entries from a gzip file. Return
     * error message if the input is not found, return null if the input is found, return the
     * expected input if input comes from one of the columns that are the values of the
     * "suggestions" key in the rules' HashMap
     *
     * @param subject the user's input, which will be validated
     * @return error message if nothing is found, null if the input is valid, expected
     * input if the input comes from another columns of the table
     * @throws IOException throw IOException if file can not be found or the file becomes corrupted
     */
    private String gzipSearch(String subject) throws IOException {
        if (this.filePath == null || this.rules == null || this.tableFormat == null) {
            throw new IllegalArgumentException("Require non-empty filepath and rules, and parserFormat");
        }
        if (rules.correct.isEmpty()) {
            throw new IllegalArgumentException("rules must contains the key correct");
        }
        try (InputStream fileStream = new FileInputStream(filePath);
             InputStream gzipStream = new GZIPInputStream(fileStream);
             Reader decoder = new InputStreamReader(gzipStream, StandardCharsets.UTF_8);
             BufferedReader reader = new BufferedReader(decoder)) {
            String line = reader.readLine();
            Map<String, Integer> col2index = this.tableFormat.parseColumns(line);
            while (true) {
                line = reader.readLine();
                if (line == null) {
                    break;
                }
                List<String> words = this.tableFormat.parseLine(line);
                ArrayList<String> correctOptions = new ArrayList<>();
                for (String rule : rules.correct) {
                    String entryInCurrentColumn = words.get(col2index.get(rule));
                    if (entryInCurrentColumn == null) {
                        continue;
                    }
                    Set<String> choices = this.tableFormat.parseEntry(entryInCurrentColumn, col2index.get(rule));
                    if (choices != null && choices.contains(subject)) {
                        return null;
                    } else if (entryInCurrentColumn.equals(subject)) {
                        return null;
                    }
                    correctOptions.add(entryInCurrentColumn);
                }
                for (String suggestion : rules.suggestions) {
                    String correctColumnEntry = words.get(col2index.get(suggestion));
                    if (correctColumnEntry == null) {
                        continue;
                    }
                    Set<String> choices = this.tableFormat.parseEntry(correctColumnEntry, col2index.get(suggestion));
                    if (choices != null && choices.contains(subject)) {
                        return "Entered " + subject + ". Expected: any one of " + correctOptions.toString();
                    } else if (correctColumnEntry.equals(subject)) {
                        return "Entered " + subject + ". Expected: any one of " + correctOptions.toString();
                    }
                }
            }
        }
        return "Entered: " + subject + ". Expected: an entry from the columns " + rules.correct;
    }

    public static void main(String[] args) throws IOException {
        long startTime = System.currentTimeMillis();
        EnumFormatValidator.Builder builder = new EnumFormatValidator.Builder()
                .setParserFormat(new TableFormat().addFormat(new String[]{"\t", "\t", "\t"})
                        .addEntryPattern(2, ", ")
                        .addEntryPattern(3, ", "))
                .setFilePath("src/main/resources/GenBankControlledVocabulary.tsv.gz")
                .setRules(new Rules().addExpectedColumn(Arrays.asList("Scientific_Name", "Synonyms"))
                        .addSuggestedColumn(Arrays.asList("Synonyms", "Other_Common_Name")))
                .setFormatTag("animal_subject");
                //.loadDataGzip();
        FormatValidator fv = builder.build();
        System.out.println(fv.validate("cat"));
        long endTime = System.currentTimeMillis();
        System.out.println("Execution time: " + (endTime-startTime)/1000.0 + "s");
    }
}
