#include <mex.hpp>
#include <mexAdapter.hpp>
#include <MatlabDataArray.hpp>


#include <random>


namespace JacobianDistortions
{
    
template<typename real>
struct Mat3
{
    real x[9];

    Mat3()
    {
        memset(x, 0, 9 * sizeof(real));
    }

    Mat3(const real* y)
    {
        memcpy(x, y, 9 * sizeof(real));
    }

    Mat3(const real* y1,
         const real* y2,
         const real* y3)
    {
        memcpy(x, y1, 3 * sizeof(real));
        memcpy(x + 3, y2, 3 * sizeof(real));
        memcpy(x + 6, y3, 3 * sizeof(real));
    }

    Mat3(const Mat3& M)
    {
        memcpy(x, M.x, 9 * sizeof(real));
    }

    void Scaled(real d)
    {
        for (int i = 0; i < 9; ++i)
            x[i] *= d;
    }

    void Subtract(const real* y)
    {
        x[0] -= y[0];
        x[1] -= y[1];
        x[2] -= y[2];
        x[3] -= y[0];
        x[4] -= y[1];
        x[5] -= y[2];
        x[6] -= y[0];
        x[7] -= y[1];
        x[8] -= y[2];
    }

    Mat3 MatMul(const Mat3& M)
    {
        Mat3 R;
        for (int i = 0; i < 3; ++i)
        {
            for (int k = 0; k < 3; ++k)
            {
                for (int j = 0; j < 3; ++j)
                {
                    R.x[i * 3 + j] += x[i * 3 + k] * M.x[k * 3 + j];
                }
            }
        }
        return R;
    }


    real Determinant() const
    {
        return x[0] * (x[4] * x[8] - x[5] * x[7]) -
               x[1] * (x[3] * x[8] - x[5] * x[6]) +
               x[2] * (x[3] * x[7] - x[4] * x[6]);
    }

    void Transpose()
    {
        std::swap(x[1], x[3]);
        std::swap(x[2], x[6]);
        std::swap(x[5], x[7]);
    }

    Mat3 Transposed() const
    {
        Mat3 M(*this);
        M.Transpose();
        return M;
    }

    Mat3 Inversed() const
    {
        Mat3 M;
        // Adjugate matrix
        M.x[0] = x[4] * x[8] - x[5] * x[7]; // +
        M.x[1] = x[2] * x[7] - x[1] * x[8]; // -
        M.x[2] = x[1] * x[5] - x[2] * x[4]; // +
        M.x[3] = x[5] * x[6] - x[3] * x[8]; // -
        M.x[4] = x[0] * x[8] - x[2] * x[6]; // +
        M.x[5] = x[2] * x[3] - x[0] * x[5]; // -
        M.x[6] = x[3] * x[7] - x[4] * x[6]; // +
        M.x[7] = x[1] * x[6] - x[0] * x[7]; // -
        M.x[8] = x[0] * x[4] - x[1] * x[3]; // +

        // Determinant (avoid recomputing terms)
        real d = x[0] * M.x[0] + x[1] * M.x[3] + x[2] * M.x[6];

        M.Scaled(1 / d);
        return M;
    }

};


} // namespace JacobianDistortions


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
        if (inputs[1].getDimensions().size() != 2 && inputs[1].getDimensions()[0] != 3)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Second input must be a 3-by-N 2D matrix.") }
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

        matlab::data::ArrayFactory factory;

        // Retrieve indices
        const int* tets = getDataPtr<int>(inputs[2]);

        // Single or real?
        if (inputs[0].getType() == matlab::data::ArrayType::DOUBLE)
        {
            const double* v1 = getDataPtr<double>(inputs[0]);
            const double* v2 = getDataPtr<double>(inputs[1]);
            const int32_t* t = getDataPtr<int32_t>(inputs[2]);
            unsigned long long ntets = inputs[2].getDimensions()[1];
            outputs[0] = factory.createArray<double>(matlab::data::ArrayDimensions({ ntets, 1 }));

            for (unsigned long long i = 0; i < ntets; ++i)
            {
                // Get matrix T1
                JacobianDistortions::Mat3<double> T1(v1 + 3 * t[4 * i + 1], 
                                                     v1 + 3 * t[4 * i + 2], 
                                                     v1 + 3 * t[4 * i + 3]);
                T1.Subtract(v1 + 3 * t[4 * i]);
                // Get matrix T2
                JacobianDistortions::Mat3<double> T2(v2 + 3 * t[4 * i + 1], 
                                                     v2 + 3 * t[4 * i + 2], 
                                                     v2 + 3 * t[4 * i + 3]);
                T2.Subtract(v2 + 3 * t[4 * i]);
                // Get Jacobian
                JacobianDistortions::Mat3<double> J = T1.Inversed().MatMul(T2);
                outputs[0][i] = J.Determinant();
            }
        }
        else
        {
            const float* v1 = getDataPtr<float>(inputs[0]);
            const float* v2 = getDataPtr<float>(inputs[1]);
            const int32_t* t = getDataPtr<int32_t>(inputs[2]);
            unsigned long long ntets = inputs[2].getDimensions()[1];
            outputs[0] = factory.createArray<float>(matlab::data::ArrayDimensions({ ntets, 1 }));

            for (unsigned long long i = 0; i < ntets; ++i)
            {
                // Get matrix T1
                JacobianDistortions::Mat3<float> T1(v1 + 3 * t[4 * i + 1], 
                                                     v1 + 3 * t[4 * i + 2], 
                                                     v1 + 3 * t[4 * i + 3]);
                T1.Subtract(v1 + 3 * t[4 * i]);
                // Get matrix T2
                JacobianDistortions::Mat3<float> T2(v2 + 3 * t[4 * i + 1], 
                                                     v2 + 3 * t[4 * i + 2], 
                                                     v2 + 3 * t[4 * i + 3]);
                T2.Subtract(v2 + 3 * t[4 * i]);
                // Get Jacobian
                JacobianDistortions::Mat3<float> J = T1.Inversed().MatMul(T2);
                outputs[0][i] = J.Determinant();
            }
        }
    }
};