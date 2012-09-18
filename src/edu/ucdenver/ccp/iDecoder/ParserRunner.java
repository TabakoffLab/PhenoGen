package edu.ucdenver.ccp.iDecoder;

import java.io.IOException;

/**
 * Use to run all of the Parsers.
 */
public class ParserRunner {
    private final String outputDirectory;

    public ParserRunner() {
        this.outputDirectory = 
            (String) PropertiesHelper.getFileMap().get("outputDirectory");
    }

    public static void main(String[] args) throws IOException {

        ParserRunner runner = new ParserRunner();
        runner.runAffyExonParser();
        runner.runAffyParser();
        runner.runCodeLinkParser();
        runner.runEnsemblParser();
        runner.runFlyBaseParser();
        runner.runMGIParser();
        runner.runNCBIParser();
        runner.runRGDParser();
        runner.runSwissProtParser();

    }

    private void runAffyParser() throws IOException {
        long startTime = System.currentTimeMillis();
        new AffymetrixParser(outputDirectory).processAllInputFiles();
        System.out.println("Affymetrix total\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
    }

    private void runAffyExonParser() throws IOException {
        long startTime = System.currentTimeMillis();
        new AffymetrixExonParser(outputDirectory).processAllInputFiles();
        System.out.println("Affymetrix Exon total\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
    }

    private void runCodeLinkParser() throws IOException {
        long startTime = System.currentTimeMillis();
        new CodeLinkParser(outputDirectory).processAllInputFiles();
        System.out.println("CodeLink total\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
    }

    private void runEnsemblParser() throws IOException {
        long startTime = System.currentTimeMillis();
        new EnsemblParser(outputDirectory).processAllInputFiles();
        System.out.println("Ensembl total\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
    }

    private void runFlyBaseParser() throws IOException {
        long startTime = System.currentTimeMillis();
        new FlyBaseParser(outputDirectory).processAllInputFiles();
        System.out.println("FlyBase total\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
    }

    private void runMGIParser() throws IOException {
        long startTime = System.currentTimeMillis();
        new MGIParser(outputDirectory).processAllInputFiles();
        System.out.println("MGI total\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
    }

    private void runNCBIParser() throws IOException {
        long startTime = System.currentTimeMillis();
        new NCBIParser(outputDirectory).processAllInputFiles();
        System.out.println("NCBI total\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
    }

    private void runRGDParser() throws IOException {
        long startTime = System.currentTimeMillis();
        new RGDParser(outputDirectory).processAllInputFiles();
        System.out.println("RGD total\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
    }

    private void runSwissProtParser() throws IOException {
        long startTime = System.currentTimeMillis();
        new SwissProtParser(outputDirectory).processAllInputFiles();
        System.out.println("SwissProt total\t"
                + (System.currentTimeMillis() - startTime) / 1000 + " seconds");
    }
}
