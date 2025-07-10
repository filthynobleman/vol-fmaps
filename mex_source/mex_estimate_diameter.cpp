#include <mex.hpp>
#include <mexAdapter.hpp>
#include <MatlabDataArray.hpp>

#include <queue>


namespace EstimateDiameter
{
    
template<typename real>
struct Vec3
{
    real x;
    real y;
    real z;

    Vec3(real x, real y, real z) : x(x), y(y), z(z) { }
    Vec3(const real* v) : x(v[0]), y(v[1]), z(v[2]) { }
    Vec3(const EstimateDiameter::Vec3<real>& V) : x(V.x), y(V.y), z(V.z) { }

    real dist2(const EstimateDiameter::Vec3<real>& V) const
    {
        double xx = x - V.x;
        double yy = y - V.y;
        double zz = z - V.z;
        return xx * xx + yy * yy + zz * zz;
    }

    real dist(const EstimateDiameter::Vec3<real>& V) const { return std::sqrt(dist2(V)); }
};


template<typename real>
class Graph
{
private:
    std::vector<EstimateDiameter::Vec3<real>> m_Pos;
    std::vector<std::pair<int, real>> m_Edges;
    std::vector<int> m_Idxs;

public:
    Graph(const real* vdata, int nv, const int* edata, int ne)
    {
        m_Pos.reserve(nv);
        for (int i = 0; i < nv; ++i)
            m_Pos.emplace_back(vdata + 3 * i);
        
        m_Idxs.reserve(nv + 1);
        m_Edges.reserve(ne);
        m_Idxs.push_back(0);
        int prev = 0;
        for (int i = 0; i < ne; ++i)
        {
            int cur = edata[2 * i];
            while (cur != prev)
            {
                m_Idxs.push_back(i);
                prev++;
            }
            real d = m_Pos[edata[2 * i]].dist(m_Pos[edata[2 * i + 1]]);
            m_Edges.emplace_back(edata[2 * i + 1], d);
        }
        while (m_Idxs.size() < nv + 1)
            m_Idxs.push_back(ne);
    }
    ~Graph() { }

    real MaxDistance(int i) const
    {
        std::vector<real> dists;
        dists.resize(m_Pos.size(), std::numeric_limits<real>::infinity());

        std::priority_queue<std::pair<real, int>, std::vector<std::pair<real, int>>, std::greater<std::pair<real, int>>> pq;
        dists[i] = 0.0;
        pq.emplace(dists[i], i);
        while (!pq.empty())
        {
            auto cur = pq.top();
            pq.pop();

            int nadj = m_Idxs[cur.second + 1];
            for (int kk = m_Idxs[cur.second]; kk < nadj; ++kk)
            {
                if (kk >= m_Edges.size())
                {
                    std::cout << "Issue with vertex " << cur.second << std::endl;
                    std::cout << "    Trying to access edge " << kk << ", but graph has only " << m_Edges.size() << " edges." << std::endl;
                    std::cout << "    CSR starts at " << m_Idxs[cur.second] << " and stops at " << m_Idxs[cur.second + 1] << std::endl;
                    break;
                }
                int k = m_Edges[kk].first;
                real w = m_Edges[kk].second;
                w += dists[cur.second];
                if (dists[k] <= w)
                    continue;
                dists[k] = w;
                pq.emplace(w, k);
            }
        }

        real MaxD = 0.0;
        for (int j = 0; j < dists.size(); ++j)
        {
            // Replace infinite geodesics (i.e., disconnected components) with Euclidean distance
            if (std::isinf(dists[j]))
                dists[j] = m_Pos[i].dist(m_Pos[j]);
            MaxD = std::max(MaxD, dists[j]);
        }
        return MaxD;
    }
};


} // namespace EstimateDiameter





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
        if (inputs[1].getDimensions().size() != 2 && inputs[1].getDimensions()[0] != 2)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Second input must be a 2-by-N 2D matrix.") }
                             ));
        }

        if (inputs[1].getType() != matlab::data::ArrayType::INT32 && inputs[1].getType() != matlab::data::ArrayType::INT32)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Second input must be int32.") }
                             ));
        }

        // Third input must be a 2-rows int matrix
        if (inputs[2].getDimensions().size() != 2 && inputs[2].getDimensions()[1] != 1)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Third input must be a N-by-1 array.") }
                             ));
        }

        if (inputs[2].getType() != matlab::data::ArrayType::INT32 && inputs[2].getType() != matlab::data::ArrayType::INT32)
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
        const int* edges = getDataPtr<int>(inputs[1]);
        const int* samples = getDataPtr<int>(inputs[2]);

        // Single or double?
        if (inputs[0].getType() == matlab::data::ArrayType::DOUBLE)
        {
            const double* verts = getDataPtr<double>(inputs[0]);
            EstimateDiameter::Graph<double> G(verts, inputs[0].getDimensions()[1], edges, inputs[1].getDimensions()[1]);

            unsigned long long nsamples = inputs[2].getDimensions()[0];
            double MDist = 0.0;
            for (unsigned long long i = 0; i < nsamples; ++i)
                MDist = std::max(MDist, G.MaxDistance(samples[i]));
            outputs[0] = factory.createScalar<double>(MDist);
        }
        else
        {
            const float* verts = getDataPtr<float>(inputs[0]);
            EstimateDiameter::Graph<float> G(verts, inputs[0].getDimensions()[1], edges, inputs[1].getDimensions()[1]);

            unsigned long long nsamples = inputs[2].getDimensions()[0];
            float MDist = 0.0;
            for (unsigned long long i = 0; i < nsamples; ++i)
                MDist = std::max(MDist, G.MaxDistance(samples[i]));
            outputs[0] = factory.createScalar<float>(MDist);
        }
    }
};