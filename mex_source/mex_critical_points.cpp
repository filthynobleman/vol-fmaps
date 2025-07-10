#include <mex.hpp>
#include <mexAdapter.hpp>
#include <MatlabDataArray.hpp>



namespace CriticalPoints
{
    


} // namespace CriticalPoints


class MexFunction : public matlab::mex::Function
{
public:
    void check_args(matlab::mex::ArgumentList outputs,
                    matlab::mex::ArgumentList inputs)
    {
        std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr = getEngine();

        matlab::data::ArrayFactory factory;

        // Three inputs are needed
        if (inputs.size() < 3)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Function needs three inputs.") }
                             ));
        }

        // First input must be a three-rows single or double matrix
        if (inputs[0].getDimensions().size() != 2 && inputs[0].getDimensions()[0] != 3)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("First input must be a 3-by-N 2D matrix.") }
                             ));
        }

        if (inputs[0].getType() != matlab::data::ArrayType::DOUBLE && inputs[0].getType() != matlab::data::ArrayType::SINGLE)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("First input must be single or double.") }
                             ));
        }

        // Second input must be a 2-rows int matrix
        if (inputs[1].getDimensions().size() != 2 && inputs[1].getDimensions()[1] != 1)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Second input must be a N-by-1 vector.") }
                             ));
        }

        if (inputs[1].getType() != matlab::data::ArrayType::DOUBLE && inputs[1].getType() != matlab::data::ArrayType::SINGLE)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Second input must be single or double.") }
                             ));
        }

        // Third input must be a 2-rows int matrix
        if (inputs[2].getDimensions().size() != 2 && inputs[2].getDimensions()[0] != 4)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Third input must be a 4-by-N array.") }
                             ));
        }

        if (inputs[2].getType() != matlab::data::ArrayType::INT32)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Third input must be int32.") }
                             ));
        }

        // Function has exactly one output
        if (outputs.size() != 1)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Function has exactly one output.") }
                             ));
        }
    }

    template<typename T>
    const T* getDataPtr(matlab::data::Array arr) 
    {
        const matlab::data::TypedArray<T> arr_t = arr;
        matlab::data::TypedIterator<const T> it(arr_t.begin());
        return it.operator->();
    }

    void operator()(matlab::mex::ArgumentList outputs,
                    matlab::mex::ArgumentList inputs)
    {
        check_args(outputs, inputs);
    }
};