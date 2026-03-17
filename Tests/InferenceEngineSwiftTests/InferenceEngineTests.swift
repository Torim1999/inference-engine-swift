
import XCTest
import CoreML
@testable import InferenceEngineSwift

final class InferenceEngineTests: XCTestCase {

    // Mock MLModel for testing purposes
    class MockMLModel: MLModel {
        override func prediction(from input: MLFeatureProvider) throws -> MLFeatureProvider {
            // Simulate a successful prediction
            let outputFeatures: [String: MLFeatureValue] = [
                "outputFeatureName": MLFeatureValue(string: "mock_prediction")
            ]
            return try MLDictionaryFeatureProvider(dictionary: outputFeatures)
        }
    }

    func testPredictSuccess() throws {
        let mockModel = MockMLModel()
        let engine = InferenceEngine(model: mockModel)

        let inputFeatures: [String: MLFeatureValue] = [
            "inputFeatureName": MLFeatureValue(string: "mock_input")
        ]
        let input = try MLDictionaryFeatureProvider(dictionary: inputFeatures)

        let output = try engine.predict(input: input)
        XCTAssertNotNil(output)
        XCTAssertEqual(output.featureValue(for: "outputFeatureName")?.stringValue, "mock_prediction")
    }

    func testPredictFailure() throws {
        // A real MLModel might throw an error during prediction
        // For this mock, we'll assume the mock always succeeds unless we create a specific failing mock
        // This test primarily checks the error handling path if a real model fails.
        class FailingMLModel: MLModel {
            override func prediction(from input: MLFeatureProvider) throws -> MLFeatureProvider {
                throw NSError(domain: "MockError", code: 1, userInfo: nil)
            }
        }

        let failingModel = FailingMLModel()
        let engine = InferenceEngine(model: failingModel)

        let inputFeatures: [String: MLFeatureValue] = [
            "inputFeatureName": MLFeatureValue(string: "mock_input")
        ]
        let input = try MLDictionaryFeatureProvider(dictionary: inputFeatures)

        XCTAssertThrowsError(try engine.predict(input: input)) {
            error in
            XCTAssertTrue(error is InferenceError)
            if case InferenceError.modelPredictionFailed(let message) = error {
                XCTAssertTrue(message.contains("Prediction failed"))
            }
        }
    }

    func testInterpretOutput() throws {
        let mockModel = MockMLModel()
        let engine = InferenceEngine(model: mockModel)

        let outputFeatures: [String: MLFeatureValue] = [
            "outputFeatureName": MLFeatureValue(string: "test_value")
        ]
        let output = try MLDictionaryFeatureProvider(dictionary: outputFeatures)

        let interpreted = try engine.interpretOutput(output: output)
        XCTAssertEqual(interpreted, "Interpreted output: test_value")
    }

    func testInterpretOutputMissingFeature() throws {
        let mockModel = MockMLModel()
        let engine = InferenceEngine(model: mockModel)

        let outputFeatures: [String: MLFeatureValue] = [
            "anotherFeature": MLFeatureValue(string: "test_value")
        ]
        let output = try MLDictionaryFeatureProvider(dictionary: outputFeatures)

        XCTAssertThrowsError(try engine.interpretOutput(output: output)) {
            error in
            XCTAssertTrue(error is InferenceError)
            if case InferenceError.invalidOutput(let message) = error {
                XCTAssertTrue(message.contains("Output feature 'outputFeatureName' not found."))
            }
        }
    }
}
